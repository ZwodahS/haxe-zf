package zf.ef;

/**
	A effect that wait for anim to reach a frame to continue
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class WaitAnim extends Effect {
	@:dispose public var anim: h2d.Anim = null;
	@:dispose public var frame: Null<Int> = null;

	public function new() {
		super();
	}

	override public function update(dt: Float): Bool {
		return this.anim.currentFrame >= (this.frame != null ? this.frame : this.anim.frames.length - 1);
	}

	override public function clone(): WaitAnim {
		return WaitAnim.alloc(this.anim, this.frame);
	}

	public static function alloc(anim: h2d.Anim, frame: Null<Int> = null): WaitAnim {
		final wait = WaitAnim.__alloc__();

		wait.anim = anim;
		if (frame != null) frame = Math.clampI(frame, 0, anim.frames.length - 1);
		wait.frame = frame;

		return wait;
	}
}
