package zf.up.animations;

/**
	@stage:stable

	Pop (aka scale) the object, and return it back to the original size.
**/
class Pop extends Update {
	var duration: Float;
	var elapsed: Float = 0;
	var object: Scalable;

	var originalX: Float;
	var originalY: Float;

	public var maxScale: Float = 0.1;

	public function new(object: Scalable, duration: Float, maxScale: Float = .1) {
		super();
		this.object = object;
		this.duration = duration;

		this.originalX = this.object.scaleX;
		this.originalY = this.object.scaleY;
		this.maxScale = maxScale;
	}

	/**
		@param delta the timeelapsed
	**/
	dynamic public function scaleFunc(delta: Float): Float {
		// we will do a sine curve pop by default.
		return 1 + (Math.sin(delta * Math.PI / duration) * maxScale);
	}

	override public function isDone(): Bool {
		return this.elapsed >= this.duration;
	}

	override public function update(dt: Float) {
		this.elapsed += dt;
		if (this.elapsed >= duration) {
			this.object.scaleX = originalX;
			this.object.scaleY = originalY;
			return;
		}
		this.object.scaleX = scaleFunc(this.elapsed);
		this.object.scaleY = scaleFunc(this.elapsed);
	}
}
