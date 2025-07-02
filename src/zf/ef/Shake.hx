package zf.ef;

/**
	A effect that change the position of an object by shaking it
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Shake extends Effect {
	@:dispose public var duration: Float = 0;
	@:dispose public var shakeInterval: Float = 0;
	@:dispose public var repeat: Bool = false;
	@:dispose public var repeatIntervalMin: Float = 0.5;
	@:dispose public var repeatIntervalMax: Float = 1.0;
	@:dispose public var shakeRangeXMin: Float = 0;
	@:dispose public var shakeRangeXMax: Float = 0;
	@:dispose public var shakeRangeYMin: Float = 0;
	@:dispose public var shakeRangeYMax: Float = 0;

	@:dispose var offsetX: Float = 0;
	@:dispose var offsetY: Float = 0;
	@:dispose var delta: Float = 0;
	@:dispose var shakeDelta: Float = 0;
	@:dispose var repeatWait: Float = 0;

	function new() {
		super();
	}

	override public function clone(): Shake {
		final effect = Shake.alloc();

		effect.duration = this.duration;
		effect.shakeInterval = this.shakeInterval;
		effect.repeat = this.repeat;
		effect.repeatIntervalMin = this.repeatIntervalMin;
		effect.repeatIntervalMax = this.repeatIntervalMax;
		effect.shakeRangeXMin = this.shakeRangeXMin;
		effect.shakeRangeXMax = this.shakeRangeXMax;
		effect.shakeRangeYMin = this.shakeRangeYMin;
		effect.shakeRangeYMax = this.shakeRangeYMax;

		return effect;
	}

	override public function restart() {
		if (this.object != null) {
			this.object.x -= this.offsetX;
			this.object.y -= this.offsetY;
		}

		this.offsetX = 0;
		this.offsetY = 0;
		this.delta = 0;
		this.shakeDelta = 0;
		this.repeatWait = 0;
	}

	override public function update(dt: Float) {
		if (this.repeatWait >= 0) {
			this.repeatWait -= dt;
			if (this.repeatWait <= 0) this.repeatWait = 0;
		}

		if (this.repeatWait > 0) return false;

		this.delta += dt;
		this.shakeDelta += dt;

		if (this.delta >= this.duration) {
			// if repeat, we restart
			this.restart();
			if (this.repeat == true) {
				this.repeatWait = zf.hxd.Rand.r().randomFloat(this.repeatIntervalMin, this.repeatIntervalMax);
			} else {
				return true;
			}
		} else if (this.shakeDelta >= this.shakeInterval) {
			this.object.x -= this.offsetX;
			this.object.y -= this.offsetY;
			this.shakeDelta -= this.shakeInterval;
			this.offsetX = zf.hxd.Rand.r().randomFloat(this.shakeRangeXMin, this.shakeRangeXMax);
			this.offsetY = zf.hxd.Rand.r().randomFloat(this.shakeRangeYMin, this.shakeRangeYMax);
			this.object.x += this.offsetX;
			this.object.y += this.offsetY;
		} else {}
		return false;
	}
}
