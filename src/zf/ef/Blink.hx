package zf.ef;

/**
	Toggle the visible state of the object a few times.
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Blink extends Effect {
	// ---- Configuration ---- //

	/**
		if provided, the effect terminates after amount of blink
		each blink is a single switch, i.e. from visible to non-visible.

		even blink count means that the object will return to the same visible state.
	**/
	@:dispose var blinkCount: Null<Int> = null;

	/**
		The delta between each toggle.
	**/
	@:dispose var blinkSpeed: Float = 1;

	// ---- State ---- //
	@:dispose var delta: Float = 0;
	@:dispose var blinkCountLeft: Int = -1;

	function new() {
		super();
	}

	override public function restart() {
		this.delta = 0;
		this.blinkCountLeft = this.blinkCount ?? -1;
	}

	override public function update(dt: Float): Bool {
		this.delta += dt;

		while (this.delta >= this.blinkSpeed) {
			this.delta -= this.blinkSpeed;
			this.object.visible = !this.object.visible;
			if (this.blinkCountLeft > 0) this.blinkCountLeft -= 1;
		}

		return this.blinkCountLeft == 0;
	}

	override public function clone(): Blink {
		return Blink.blink(this.blinkCount, this.blinkSpeed);
	}

	public static function blink(blinkCount: Null<Int> = -1, blinkSpeed: Float = 1): Blink {
		final object = Blink.alloc();

		object.blinkCount = blinkCount;
		object.blinkSpeed = blinkSpeed;
		object.blinkCountLeft = object.blinkCount;

		return object;
	}
}
