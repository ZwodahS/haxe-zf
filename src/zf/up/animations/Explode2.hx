package zf.up.animations;

import zf.h2d.Particles;

typedef Explode2Conf = {
	public var ?addTo: h2d.Object;
	public var ?split: Int; // default 2

	/**
		define how long the particle stays on screen. Default to [1.0, 1.0]
	**/
	public var ?lifespan: Point2f;

	/**
		The angle of emition. [min, max]. default to [0, Math.PI * 2]
	**/
	public var ?emitAngle: Point2f;

	/**
		define how fast the particle fade in and out. Default to [1.0, 1.0]
	**/
	public var ?fadeSpeed: Point2f;

	/**
		Movespeed. Combine with angle of emition to create the particles. Default to [1.0, 1.0]
	**/
	public var ?moveSpeed: Point2f;

	/**
		Delay before moving
	**/
	public var ?moveDelay: Float;
}

/**
	Replace Explode eventually.

	Takes in a Bitmap, then split them and move them.

	By default, the spritebatch will be added to the parent of the bitmap.
**/
class Explode2 extends Update {
	public var particlesEngine: Particles;

	var original: h2d.Bitmap;
	var conf: Explode2Conf;

	/**
		Create Explode

		@param bitmap the bitmap to split
		@param conf the configuration
	**/
	public function new(bitmap: h2d.Bitmap, conf: Explode2Conf) {
		super();
		defaultConf(conf);
		this.original = bitmap;
		this.conf = conf;
		this.particlesEngine = new zf.h2d.Particles(bitmap.tile);
		initParticles();
	}

	function defaultConf(conf: Explode2Conf) {
		if (conf.split == null) conf.split = 2;
		if (conf.lifespan == null) conf.lifespan = [1.0, 1.0];
		if (conf.emitAngle == null) conf.emitAngle = [0, Math.PI * 2];
		if (conf.fadeSpeed == null) conf.fadeSpeed = [1.0, 1.0];
		if (conf.moveSpeed == null) conf.moveSpeed = [1.0, 1.0];
	}

	function initParticles() {
		inline function srand()
			return hxd.Math.srand();
		inline function rand()
			return hxd.Math.random();

		var width = this.original.tile.width / this.conf.split;
		var height = this.original.tile.height / this.conf.split;
		var particles: Array<zf.h2d.Particles.Particle> = [];
		for (x in 0...this.conf.split) {
			for (y in 0...this.conf.split) {
				var t = this.original.tile.sub(x * width, y * height, width, height);
				final particle = this.particlesEngine.emit(t);
				particle.element.x = this.original.x + x * width;
				particle.element.y = this.original.y + y * height;
				particle.element.r = this.original.color.r;
				particle.element.g = this.original.color.g;
				particle.element.b = this.original.color.b;
				particle.element.alpha = this.original.alpha;
				particle.velocityX = Random.int(-100, 100) / 50.0 * 50;
				particle.velocityY = Random.int(-100, 100) / 50.0 * 50;
				particle.lifespan = .2;
				if (this.conf.emitAngle != null) {
					final diff = this.conf.emitAngle.max - conf.emitAngle.min;
					final rad = this.conf.emitAngle.min + (diff == 0 ? 0 : rand() * diff);
					final pt = Utils.point2f;
					pt.rad = rad;
					pt.normalize();
					final diff = this.conf.moveSpeed.diff;
					final speed = this.conf.moveSpeed.min + (diff == 0 ? 0 : rand() * diff);
					particle.velocityX = pt.x * speed;
					particle.velocityY = pt.y * speed;
				}
				{
					final diff = this.conf.lifespan.diff;
					particle.lifespan = this.conf.lifespan.min + (diff == 0 ? 0 : rand() * diff);
				}

				{
					final diff = this.conf.fadeSpeed.diff;
					particle.fadeSpeed = this.conf.fadeSpeed.min + (diff == 0 ? 0 : rand() * diff);
				}
				particle.init();
				particles.push(particle);
			}
		}

		particles.shuffle();
		if (this.conf.moveDelay != null) {
			for (ind => p in particles) {
				p.moveDelay = ind * this.conf.moveDelay;
			}
		}
		if (this.original.parent != null) {
			this.original.parent.addChild(this.particlesEngine.spriteBatch);
			this.original.remove();
		}
	}

	override public function isDone(): Bool {
		return this.particlesEngine.length == 0;
	}

	override public function update(dt: Float) {
		this.particlesEngine.update(dt);
	}
}
