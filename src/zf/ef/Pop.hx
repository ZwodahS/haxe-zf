package zf.ef;

/**
	A effect that scale the object up and reset
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Pop extends Effect {
	/**
		The duration for the scaling
	**/
	@:dispose var duration: Float = 0;

	@:dispose var maxScale: Float = 0.1;

	// ---- State ---- //
	@:dispose var elapsed: Float = 0;

	@:dispose var originalX: Float = 0;
	@:dispose var originalY: Float = 0;

	@:dispose var init: Bool = false;

	/**
		@param delta the timeelapsed
	**/
	dynamic public function scaleFunc(delta: Float): Float {
		// we will do a sine curve pop by default.
		// HACK: can't handle different scale
		return this.originalX + (Math.sin(delta * Math.PI / this.duration) * maxScale);
	}

	override public function update(dt: Float) {
		if (this.init == false) {
			this.init = true;
			this.originalX = this.object.scaleX;
			this.originalY = this.object.scaleY;
		}

		this.elapsed += dt;
		if (this.elapsed >= duration) {
			this.object.scaleX = originalX;
			this.object.scaleY = originalY;
			return true;
		}

		this.object.scaleX = scaleFunc(this.elapsed);
		this.object.scaleY = scaleFunc(this.elapsed);

		return false;
	}

	public static function pop(scale: Float = .1, duration: Float = 1): Pop {
		final effect = Pop.alloc();

		effect.maxScale = scale;
		effect.duration = duration;

		return effect;
	}
}
