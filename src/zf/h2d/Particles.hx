package zf.h2d;

import h2d.SpriteBatch.BatchElement;

@:allow(zf.h2d.Particles)
class Particle {
	public var element: BatchElement;

	var parent: Particles;

	public var next: Particle;
	public var prev: Particle;

	// ---- Particles attributes ---- //
	public var velocityX: Float = 0;
	public var velocityY: Float = 0;
	public var life: Float = 0; // how long the particle has been alive
	public var lifespan: Float = 1; // how long to keep the particle alive
	public var fadeSpeed: Float = 1.0;
	public var moveDelay: Float = 0;

	/**
		Current state of the particle
		0 - recycle
		1 - rendered
		2 - fading out
		3 - to be dispose
	**/
	var state: Int = 0;

	public function new(parent: Particles) {
		this.parent = parent;
	}

	public function update(dt: Float) {
		if (this.state == 0) return;
		if (this.state == 1) {
			this.life += dt;
			if (life >= this.lifespan) this.state = 2;
		} else if (this.state == 2) {
			this.element.alpha -= dt * this.fadeSpeed;
			if (this.element.alpha <= 0) this.state = 3;
		}

		if (this.moveDelay > 0) {
			this.moveDelay -= dt;
		} else {
			this.element.x += dt * this.velocityX;
			this.element.y += dt * this.velocityY;
		}
	}

	public function init() {
		this.state = 1;
	}

	public function reset() {
		this.state = 0;
		this.life = 0;
		this.prev = null;
		this.next = null;
		this.moveDelay = 0;
	}
}

/**
	Particles

	Slightly different idea vs the one in h2d.Particles

	This provide a generic Particles to similar update.
	This is not meant to use directly but to be used to build different types of particles system.

	The update method needs to be called directly.
**/
class Particles {
	var pool: Particle;

	public var spriteBatch: h2d.SpriteBatch;

	public var length(default, null): Int = 0;

	var head: Particle;
	var tail: Particle;

	var id: Int = 0;

	public function new(tile: h2d.Tile) {
		this.spriteBatch = new h2d.SpriteBatch(tile);
	}

	public function emit(tile: h2d.Tile): Particle {
		final element = this.spriteBatch.alloc(tile);
		final particle = getParticle();
		particle.element = element;
		addParticle(particle);
		return particle;
	}

	function getParticle(): Particle {
		var particle: Particle = null;
		if (this.pool != null) {
			particle = this.pool;
			this.pool = particle.next;
			if (this.pool != null) this.pool.prev = null;
		} else {
			particle = new Particle(this);
		}
		particle.reset();
		return particle;
	}

	function addParticle(p: Particle) {
		if (this.head == null) {
			this.head = p;
			this.tail = p;
		} else {
			Assert.assert(this.tail != null);
			this.tail.next = p;
			p.prev = this.tail;
			this.tail = p;
		}
		this.length += 1;
	}

	function removeParticle(p: Particle) {
		if (this.head == p) this.head = p.next;
		if (this.tail == p) this.tail = p.prev;
		final prev = p.prev;
		final next = p.next;
		if (prev != null) prev.next = next;
		if (next != null) next.prev = prev;
		this.length -= 1;
		p.element.remove();

		if (this.pool != null) this.pool.prev = p;
		p.next = this.pool;
		this.pool = p;
	}

	public function update(dt: Float) {
		var next = this.head;

		while (next != null) {
			final curr = next;
			next = next.next;
			curr.update(dt);
			if (curr.state == 3) this.removeParticle(curr);
		}
	}
}

