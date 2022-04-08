package zf.up.animations;

/**
	Move the object by an amount then returning it back to the original spot.

	This uses sine + time elapsed to calculate the position

	by t/2, it will reaches the center point and will begin the descent.
	both axis are handled separately, hence if both are non-0, the animations might look weird.
**/
class SineMoveByDuration extends Update {
	var totalDuration: Float;
	var elapsed: Float = 0;
	var object: Positionable;

	// keep the origin position of the object
	var originX: Float;
	var originY: Float;

	var moveX: Float = 0;
	var moveY: Float = 0;

	public function new(object: Positionable, duration: Float, moveX: Float = 0, moveY: Float = 0) {
		super();
		this.object = object;
		this.totalDuration = duration;
		this.moveX = moveX;
		this.moveY = moveY;
		this.originX = object.x;
		this.originY = object.y;
	}

	static function position(start: Float, move: Float, cycle: Float): Float {
		return (Math.sin(cycle * Math.PI) * move) + start;
	}

	override public function isDone(): Bool {
		return this.elapsed >= this.totalDuration;
	}

	override public function update(dt: Float) {
		this.elapsed += dt;
		if (isDone()) {
			this.object.x = this.originX;
			this.object.y = this.originY;
			return;
		}

		final cycle = this.elapsed / this.totalDuration;
		if (this.moveX != 0) this.object.x = position(this.originX, this.moveX, cycle);
		if (this.moveY != 0) this.object.y = position(this.originY, this.moveY, cycle);
	}
}
