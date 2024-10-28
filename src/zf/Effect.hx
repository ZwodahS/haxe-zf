package zf;

/**
	Expose all the effects that is available in zf.ef in a single file.

	Mon 11:46:12 28 Oct 2024
	This makes it easier to create effect instead of having to know their underlying object.
**/
class Effect {
	public static final Effect = zf.ef.Effect;

	// ---- Expose zf.ef.Func ---- //
	inline public static function func(f: Void->Void = null, fUntil: Float->Bool = null): zf.ef.Effect {
		if (fUntil != null) return zf.ef.Func.runUntil(fUntil);
		return zf.ef.Func.run(f);
	}

	// ---- Expose zf.ef.Batch ---- //
	inline public static function batch(effects: Array<zf.ef.Effect>): zf.ef.Effect {
		return zf.ef.Batch.batch(effects);
	}

	// ---- Expose zf.ef.Chain ---- //
	inline public static function chain(effects: Array<zf.ef.Effect>): zf.ef.Effect {
		return zf.ef.Chain.chain(effects);
	}

	// ---- Expose zf.ef.Wait ---- //
	inline public static function wait(duration: Float = 0): zf.ef.Effect {
		return zf.ef.Wait.alloc(duration);
	}

	// ---- Expose zf.ef.Loop ---- //
	inline public static function loop(effect: zf.ef.Effect, loopCount: Int = -1): zf.ef.Effect {
		return zf.ef.Loop.loop(effect, loopCount);
	}

	// ---- Expose zf.ef.Alpha ---- //
	inline public static function alphaChange(alphaChange: Float = 0, duration: Float = 0): zf.ef.Effect {
		return zf.ef.Alpha.change(alphaChange, duration);
	}

	// ---- Expose zf.ef.Blink ---- //
	inline public static function blink(blinkCount: Null<Int> = -1, blinkSpeed: Float = -1): zf.ef.Effect {
		return zf.ef.Blink.blink(blinkCount, blinkSpeed);
	}

	// ---- Expose zf.ef.Move ---- //
	inline public static function moveByAmount(x: Float, y: Float, duration: Float, terminate: Bool = true,
			resetOnRemove: Bool = false): zf.ef.Effect {
		return zf.ef.Move.moveByAmount(x, y, duration, terminate, resetOnRemove);
	}

	inline public static function moveByFunc(mFunc: (Float, Point2f) -> Point2f, duration: Float,
			terminate: Bool = true, resetOnRemove: Bool = false): zf.ef.Effect {
		return zf.ef.Move.moveByFunc(mFunc, duration, terminate, resetOnRemove);
	}

	// ---- Expose zf.ef.PhysicsMove ---- //
	inline public static function moveByPhysics(duration: Float, initialVelocityX: Null<Float> = null,
			initialVelocityY: Null<Float> = null): zf.ef.PhysicsMove {
		return zf.ef.PhysicsMove.alloc(duration, initialVelocityX, initialVelocityY);
	}

	// ---- Expose zf.ef.ScaleTo ---- //
	inline public static function scaleTo(duration: Float, scaleToX: Null<Float>, scaleToY: Null<Float>): zf.ef.Effect {
		return zf.ef.ScaleTo.scaleTo(duration, scaleToX, scaleToY);
	}

	inline public static function particles(tile: h2d.Tile): zf.ef.Particles {
		return zf.ef.Particles.alloc(tile);
	}
}
