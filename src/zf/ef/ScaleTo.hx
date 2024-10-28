package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class ScaleTo extends Effect {
	// ---- Configuration ---- //
	@:dispose var scaleToX: Null<Float> = null;
	@:dispose var scaleToY: Null<Float> = null;
	@:dispose var duration: Float = 0;
	@:dispose var init: Bool = false;

	@:dispose var scaleAmountX: Null<Float> = null;
	@:dispose var scaleAmountY: Null<Float> = null;
	@:dispose var delta: Float = 0;
	@:dispose var scaleX: Float = 0;
	@:dispose var scaleY: Float = 0;

	function new() {
		super();
	}

	override public function clone(): ScaleTo {
		return ScaleTo.scaleTo(this.duration, this.scaleToX, this.scaleToY);
	}

	override public function restart() {
		super.restart();

		if (this.object != null) {
			this.object.scaleX -= this.scaleX;
			this.object.scaleY -= this.scaleY;
		}

		this.delta = 0;
		this.scaleX = 0;
		this.scaleY = 0;
	}

	override function update(dt: Float) {
		if (this.delta >= this.duration) return true;
		if (this.init == false) {
			this.init = true;
			if (this.scaleToX != null) this.scaleAmountX = this.scaleToX - object.scaleX;
			if (this.scaleToY != null) this.scaleAmountY = this.scaleToY - object.scaleY;
		}

		this.delta += dt;
		if (this.delta >= this.duration) this.delta = this.duration;

		if (this.scaleAmountX != null) {
			this.object.scaleX -= this.scaleX;
			this.scaleX = this.delta / this.duration * scaleAmountX;
			this.object.scaleX += this.scaleX;
		}

		if (this.scaleAmountY != null) {
			this.object.scaleY -= this.scaleY;
			this.scaleY = this.delta / this.duration * scaleAmountY;
			this.object.scaleY += this.scaleY;
		}

		return this.delta >= this.duration;
	}

	public static function scaleTo(duration: Float, scaleToX: Null<Float>, scaleToY: Null<Float>): ScaleTo {
		final effect = ScaleTo.alloc();

		effect.duration = duration;
		effect.scaleToX = scaleToX;
		effect.scaleToY = scaleToY;

		return effect;
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		final e: ScaleTo = cast super.applyTo(object, copy, updater, whenDone);
		if (copy == true) return e;

		return e;
	}
}
