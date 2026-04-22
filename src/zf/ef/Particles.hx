package zf.ef;

import zf.h2d.Particles.Particle;

/**
	Particles is a slightly different effect compared to the other effects.
	Particles can stay for a long time after it is constructed and new particles can be emitted
	via the same Particles class.

	This makes this more like a Particles emitter
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Particles extends Effect {
	// ---- Configuration ---- //
	@:dispose public var tile: h2d.Tile = null;

	/**
		The bound to emit the particles, default to the bound of the object that it is applied to.
	**/
	@:dispose var emitBounds: h2d.col.Bounds = null;

	/**
		define how long the particle stays on screen. Default to [1.0, 1.0]
	**/
	@:dispose var lifespan: Point2f;

	/**
		define how fast the particle fade in and out. Default to [1.0, 1.0]
	**/
	@:dispose var fadeSpeed: Point2f;

	/**
		define how often the particle is spawn. Default 1.0
	**/
	@:dispose var emitDelay: Float = 1.0;

	/**
		Define the starting alpha. Default 1.0
	**/
	@:dispose var initialAlpha: Point2f;

	/**
		Additional way to init the particle.
		Use this if the default settings is not enough
	**/
	@:dispose var initParticle: Particle->Void = null;

	/**
		The angle of emition. [min, max].
	**/
	@:dispose var emitAngle: Point2f;

	/**
		Movespeed. Combine with angle of emition to create the particles
	**/
	@:dispose var moveSpeed: Point2f;

	/**
		Maximum number of particles at once. Default 100
	**/
	@:dispose var maxParticles: Int = 100;

	/**
		Maximum number of particles to spawn. Default null
		If provided, the effect will be removed once all particles is spawn.
	**/
	@:dispose var maxSpawn: Null<Int> = null;

	/**
		If true, this is a permanent particle effects and we use spawn more to spawn particles.
		This means update will never return true
	**/
	@:dispose var persist: Bool = false;

	// ---- Run time data ---- //
	var particles: zf.h2d.Particles;

	@:dispose var toSpawn: Int = 0;
	@:dispose var spawned: Int = 0;

	// precalculate the emitX and emitY range
	@:dispose var emitX: Point2i;
	@:dispose var emitY: Point2i;

	function new() {
		super();
	}

	public function spawnMore(i: Int) {
		this.toSpawn += i;
	}

	var spawnDelta: Float = 0;

	override public function update(dt: Float): Bool {
		this.particles.update(dt);
		this.spawnDelta += dt;

		inline function shouldSpawn(): Bool {
			if (this.particles.length >= this.maxParticles) return false;
			if (this.maxSpawn != null && this.maxSpawn <= this.spawned) return false;
			if (this.persist == true && this.toSpawn == 0) return false;
			return true;
		}

		while (this.spawnDelta > this.emitDelay) {
			this.spawnDelta -= this.emitDelay;
			if (shouldSpawn()) {
				final particle = this.particles.emit(this.tile);
				_initParticle(particle);
				if (this.toSpawn > 0) this.toSpawn -= 1;
				this.spawned += 1;
			}
		}

		if (this.persist == true) return false;
		if (this.maxSpawn != null && this.maxSpawn <= this.spawned && this.particles.length == 0) return true;
		return false;
	}

	public static function alloc(tile: h2d.Tile): Particles {
		final effect = Particles.__alloc__();

		effect.tile = tile;
		effect.particles = new zf.h2d.Particles(tile);
		effect.lifespan = Point2f.alloc(1.0, 1.0);
		effect.fadeSpeed = Point2f.alloc(1.0, 1.0);
		effect.initialAlpha = Point2f.alloc(1.0, 1.0);
		effect.emitAngle = Point2f.alloc(0, Math.PI * 2);
		effect.moveSpeed = Point2f.alloc(1, 1);

		return effect;
	}

	function _initParticle(particle: Particle) {
		inline function srand()
			return hxd.Math.srand();
		inline function rand()
			return hxd.Math.random();
		// set the particle position
		particle.element.x = (rand() * emitX.diff) + emitX.min;
		particle.element.y = (rand() * emitY.diff) + emitY.min;

		{
			final diff = this.initialAlpha.diff;
			particle.element.a = this.initialAlpha.min + (diff == 0 ? 0 : rand() * diff);
		}

		if (this.emitAngle != null) {
			final diff = this.emitAngle.max - this.emitAngle.min;
			final rad = this.emitAngle.min + (diff == 0 ? 0 : rand() * diff);
			final pt = Point2f.alloc(1, 0);
			pt.rad = rad;
			pt.normalize();
			final diff = this.moveSpeed.diff;
			final moveSpeed = this.moveSpeed.min + (diff == 0 ? 0 : rand() * diff);
			particle.velocityX = pt.x * moveSpeed;
			particle.velocityY = pt.y * moveSpeed;
			pt.dispose();
		}

		{
			final diff = this.lifespan.diff;
			particle.lifespan = this.lifespan.min + (diff == 0 ? 0 : rand() * diff);
		}

		{
			final diff = this.fadeSpeed.diff;
			particle.fadeSpeed = this.fadeSpeed.min + (diff == 0 ? 0 : rand() * diff);
		}

		if (this.initParticle != null) this.initParticle(particle);
		particle.init();
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		final effect: Particles = cast super.applyTo(object, copy, updater, whenDone);
		if (copy == true) return effect;

		effect.object.addChild(effect.particles.spriteBatch);

		if (effect.emitBounds == null) effect.emitBounds = object.getBounds(object);

		if (effect.emitBounds.width < effect.tile.width) {
			effect.emitX = [Std.int(effect.emitBounds.xMin), Std.int(effect.emitBounds.xMin)];
		} else {
			effect.emitX = [Std.int(effect.emitBounds.xMin), Std.int(effect.emitBounds.xMax - tile.width)];
		}

		if (emitBounds.height < effect.tile.height) {
			effect.emitY = [Std.int(effect.emitBounds.yMin), Std.int(effect.emitBounds.yMin)];
		} else {
			effect.emitY = [Std.int(effect.emitBounds.yMin), Std.int(effect.emitBounds.yMax - tile.height)];
		}

		return effect;
	}

	override public function onEffectRemoved() {
		this.particles.spriteBatch.remove();
	}

	public function reset() {
		this.particles.spriteBatch.remove();
	}

	public function setEmitDelay(delay: Float): Particles {
		this.emitDelay = delay;
		return this;
	}

	public function setInitialAlpha(min: Float, max: Float): Particles {
		this.initialAlpha.min = min;
		this.initialAlpha.max = max;
		return this;
	}

	public function setEmitBounds(bounds: h2d.col.Bounds): Particles {
		this.emitBounds = bounds;
		return this;
	}

	public function setLifeSpan(min: Float, max: Float): Particles {
		this.lifespan.min = min;
		this.lifespan.max = max;
		return this;
	}

	public function setFadeSpeed(min: Float, max: Float): Particles {
		this.fadeSpeed.min = min;
		this.fadeSpeed.max = max;
		return this;
	}

	public function setEmitAngle(min: Float, max: Float): Particles {
		this.emitAngle.min = min;
		this.emitAngle.max = max;
		return this;
	}

	public function setMoveSpeed(min: Float, max: Float): Particles {
		this.moveSpeed.min = min;
		this.moveSpeed.max = max;
		return this;
	}

	public function setMaxSpawn(maxSpawn: Int): Particles {
		/**
			Mon 15:57:57 28 Oct 2024
			I think maxSpawn can be merged into toSpawn but I am too tired to think about it right now
			It aren't broken, so I aren't gonna fix it.
		**/
		this.maxSpawn = maxSpawn;
		return this;
	}

	public function setMaxParticles(maxParticles: Int): Particles {
		this.maxParticles = maxParticles;
		return this;
	}

	public function setPersist(persist: Bool): Particles {
		this.persist = persist;
		return this;
	}
}
