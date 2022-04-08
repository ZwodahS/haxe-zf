package zf.up.animations;

class MoveBySpeedByDuration extends Update {
	var object: Positionable;
	var moveSpeed: Point2f;
	var moveDuration: Float;
	var moveLeft: Float;

	public function new(object: Positionable, moveDuration: Float, moveSpeeds: Point2f = null, moveSpeed: Float = 1) {
		super();
		this.object = object;
		this.moveSpeed = moveSpeeds != null ? moveSpeeds : [moveSpeed, moveSpeed];
		this.moveDuration = moveDuration;
		this.moveLeft = moveDuration >= 0 ? moveDuration : 0;
	}

	override public function isDone(): Bool {
		return (this.moveDuration >= 0 && this.moveLeft == 0);
	}

	override public function update(dt: Float) {
		if (this.isDone()) {
			return;
		}

		if (this.moveLeft >= 0) {
			dt = Math.min(this.moveLeft, dt);
		}

		this.object.x += dt * this.moveSpeed.x;
		this.object.y += dt * this.moveSpeed.y;
		this.moveLeft -= dt;
	}
}
