package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class PhysicsMove extends Effect {
	@:dispose var delta: Float = 0;
	@:dispose var velocityX: Float = 0;
	@:dispose var velocityY: Float = 0;
	@:dispose var movedAmount: Point2f = null;

	// ---- Configuration ---- //

	/**
		The rotation velocity
	**/
	@:dispose var angularVelocity: Null<Float> = null;

	/**
		Acceleration in the x axis
	**/
	@:dispose var accelerationX: Float = 0;

	/**
		Acceleration in the y axis
	**/
	@:dispose var accelerationY: Float = 0;

	/**
		Deceleration in the x axis
	**/
	@:dispose var decelerationX: Float = 0;

	/**
		Deceleration in the y axis
	**/
	@:dispose var decelerationY: Float = 0;

	/**
		Initial velocity in the x axis
	**/
	@:dispose var initialVelocityX: Null<Float> = null;

	/**
		Initial velocity in the y axis
	**/
	@:dispose var initialVelocityY: Null<Float> = null;

	/**
		Terminal velocity in the x axis
	**/
	@:dispose var terminalVelocityX: Null<Float> = null;

	/**
		Terminal velocity in the y axis
	**/
	@:dispose var terminalVelocityY: Null<Float> = null;

	/**
		The duration to apply the effect
	**/
	@:dispose var duration: Float = 0;

	function new() {
		super();
	}

	override public function restart() {
		super.restart();
		this.velocityX = 0;
		this.velocityY = 0;
		this.movedAmount.x = 0;
		this.movedAmount.y = 0;
	}

	public function setAngularVelocity(ang: Float): PhysicsMove {
		this.angularVelocity = ang;
		return this;
	}

	public function accelerate(x: Float, y: Float): PhysicsMove {
		this.accelerationX = x;
		this.accelerationY = y;
		return this;
	}

	public function decelerate(x: Float, y: Float): PhysicsMove {
		this.decelerationX = x;
		this.decelerationY = y;
		return this;
	}

	public function setTerminalVelocity(x: Null<Float>, y: Null<Float>): PhysicsMove {
		this.terminalVelocityX = x;
		this.terminalVelocityY = y;
		return this;
	}

	override public function clone(): PhysicsMove {
		final effect = PhysicsMove.alloc(this.duration, this.initialVelocityX, this.initialVelocityY);

		effect.angularVelocity = this.angularVelocity;
		effect.accelerationX = this.accelerationX;
		effect.accelerationY = this.accelerationY;
		effect.decelerationX = this.decelerationX;
		effect.decelerationY = this.decelerationY;
		effect.terminalVelocityX = this.terminalVelocityX;
		effect.terminalVelocityY = this.terminalVelocityY;
		effect.duration = this.duration;

		return effect;
	}

	override public function update(dt: Float): Bool {
		if (this.delta >= this.duration) return true;
		this.delta += dt;
		if (this.delta >= this.duration) this.delta = this.duration;

		// remove the moved amount
		this.object.x -= this.movedAmount.x;
		this.object.y -= this.movedAmount.y;

		// update the velocity
		if (this.accelerationX != 0) {
			this.velocityX += dt * this.accelerationX;
			if (this.terminalVelocityX != null) {
				if (Math.abs(this.velocityX) > this.terminalVelocityX) {
					this.velocityX = Math.sign(this.velocityX) * this.terminalVelocityX;
				}
			}
		} else if (this.decelerationX != 0) {
			if (this.velocityX > 0) {
				this.velocityX -= dt * this.decelerationX;
				if (this.velocityX < 0) this.velocityX = 0;
			} else if (this.velocityX < 0) {
				this.velocityX += dt * this.decelerationX;
				if (this.velocityX > 0) this.velocityX = 0;
			}
		}

		if (this.accelerationY != 0) {
			this.velocityY += dt * this.accelerationY;
			if (this.terminalVelocityY != null) {
				if (Math.abs(this.velocityY) > this.terminalVelocityY) {
					this.velocityY = Math.sign(this.velocityY) * this.terminalVelocityY;
				}
			}
		} else if (this.decelerationY != 0) {
			if (this.velocityY > 0) {
				this.velocityY -= dt * this.decelerationY;
				if (this.velocityY < 0) this.velocityY = 0;
			} else if (this.velocityY < 0) {
				this.velocityY += dt * this.decelerationY;
				if (this.velocityY > 0) this.velocityY = 0;
			}
		}

		// update the moveAmount
		this.movedAmount.x += this.velocityX * dt;
		this.movedAmount.y += this.velocityY * dt;

		this.object.x += this.movedAmount.x;
		this.object.y += this.movedAmount.y;

		if (this.angularVelocity != 0) {
			this.object.rotate(this.angularVelocity * dt);
		}

		return false;
	}

	public static function alloc(duration: Float, initialVelocityX: Null<Float> = null,
			initialVelocityY: Null<Float> = null): PhysicsMove {
		final effect = PhysicsMove.__alloc__();

		effect.movedAmount = [];
		effect.duration = duration;
		effect.initialVelocityX = initialVelocityX;
		effect.initialVelocityY = initialVelocityY;

		return effect;
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		final eff: PhysicsMove = cast super.applyTo(object, copy, updater, whenDone);
		if (copy == true) return eff;

		eff.velocityX = eff.initialVelocityX ?? 0;
		eff.velocityY = eff.initialVelocityY ?? 0;

		return eff;
	}
}
/**
	Wed 19:46:54 23 Oct 2024
	This is currently untested. Even the old PhysicsMoveEffect is not tested.
	Somehow the code is copied over from somewhere but no one is using it yet.
**/
