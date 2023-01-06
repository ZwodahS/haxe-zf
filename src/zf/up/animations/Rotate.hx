package zf.up.animations;

/**
	@stage:stable
**/
class Rotate extends Update {
	var object: Rotatable;
	var rotateSpeed: Float; // in radians
	var duration: Null<Float>; // in seconds
	var timeElapsed: Float;

	public function new(object: Rotatable, rotateSpeed: Float, duration: Null<Float> = null) {
		super();
		this.object = object;
		this.rotateSpeed = rotateSpeed;
		this.duration = duration;
		this.timeElapsed = 0;
	}

	override public function isDone(): Bool {
		return this.duration != null && this.duration <= this.timeElapsed;
	}

	override public function update(dt: Float) {
		if (this.isDone()) return;
		this.timeElapsed += dt;
		if (this.duration != null && this.timeElapsed >= this.duration) {
			this.timeElapsed = duration;
		}
		this.object.rotation = (this.timeElapsed * Math.PI * this.rotateSpeed);
	}
}
