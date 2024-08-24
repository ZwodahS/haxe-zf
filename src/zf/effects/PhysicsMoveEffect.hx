package zf.effects;

typedef PhysicsMoveEffectConf = {
	> Effect.EffectConf,

	public var ?angularVelocity: Float;
	public var ?acceleration: Point2f; // acceleration in the 2 axis, always applies
	public var ?deceleration: Point2f; // deceleration will try to reduce velocity to 0 by that amount
	public var ?initialVelocity: Point2f; // the initial of the object
	public var ?terminalVelocity: Point2f;
	public var ?duration: Float;
}

class PhysicsMoveEffect extends Effect {
	var conf: PhysicsMoveEffectConf;
	var object: h2d.Object;

	var delta: Float = 0;

	var velocity: Point2f;
	var movedAmount: Point2f;

	public function new(conf: PhysicsMoveEffectConf) {
		super(conf);
		defaultConf(conf);
		this.conf = conf;

		this.velocity = [conf.initialVelocity.x, conf.initialVelocity.y];
		this.movedAmount = [0, 0];
	}

	function defaultConf(conf: PhysicsMoveEffectConf) {
		if (conf.acceleration == null) conf.acceleration = [0, 0];
		if (conf.deceleration == null) conf.deceleration = [0, 0];
		if (conf.initialVelocity == null) conf.initialVelocity = [0, 0];
		if (conf.terminalVelocity == null) conf.terminalVelocity = [-1, -1];
		if (conf.angularVelocity == null) conf.angularVelocity = 0;
	}

	override function reset() {
		super.reset();
		this.velocity.x = this.conf.initialVelocity.x;
		this.velocity.y = this.conf.initialVelocity.y;
		this.movedAmount.x = 0;
		this.movedAmount.y = 0;
	}

	override public function update(dt: Float): Bool {
		if (this.conf.duration != -1 && this.delta >= conf.duration) return true;
		this.delta += dt;
		if (conf.duration != -1 && this.delta >= conf.duration) this.delta = conf.duration;

		this.object.x -= this.movedAmount.x; // remove the moved amount first
		this.object.y -= this.movedAmount.y;

		// update the velocity
		if (this.conf.acceleration.x != 0) {
			this.velocity.x += dt * this.conf.acceleration.x;
			if (this.conf.terminalVelocity.x != -1) {
				if (Math.abs(this.velocity.x) > this.conf.terminalVelocity.x) {
					this.velocity.x = Math.sign(this.velocity.x) * this.conf.terminalVelocity.x;
				}
			}
		} else if (this.conf.deceleration.x != 0) {
			if (this.velocity.x > 0) {
				this.velocity.x -= dt * this.conf.deceleration.x;
				if (this.velocity.x < 0) this.velocity.x = 0;
			} else if (this.velocity.x < 0) {
				this.velocity.x += dt * this.conf.deceleration.x;
				if (this.velocity.x > 0) this.velocity.x = 0;
			}
		}

		if (this.conf.acceleration.y != 0) {
			this.velocity.y += dt * this.conf.acceleration.y;
			if (this.conf.terminalVelocity.y != -1) {
				if (Math.abs(this.velocity.y) > this.conf.terminalVelocity.y) {
					this.velocity.y = Math.sign(this.velocity.y) * this.conf.terminalVelocity.y;
				}
			}
		} else if (this.conf.deceleration.y != 0) {
			if (this.velocity.y > 0) {
				this.velocity.y -= dt * this.conf.deceleration.y;
				if (this.velocity.y < 0) this.velocity.y = 0;
			} else if (this.velocity.y < 0) {
				this.velocity.y += dt * this.conf.deceleration.y;
				if (this.velocity.y > 0) this.velocity.y = 0;
			}
		}

		// update the moveAmount
		this.movedAmount.x += this.velocity.x * dt;
		this.movedAmount.y += this.velocity.y * dt;

		this.object.x += this.movedAmount.x;
		this.object.y += this.movedAmount.y;

		if (this.conf.angularVelocity != 0) {
			this.object.rotate(this.conf.angularVelocity * dt);
		}

		return false;
	}

	override public function clone(): PhysicsMoveEffect {
		return new PhysicsMoveEffect(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		this.object = object;
		return this;
	}
}
