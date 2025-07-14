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

	inline public static function waitAnim(anim: h2d.Anim, frame: Null<Int> = null): zf.ef.WaitAnim {
		return zf.ef.WaitAnim.alloc(anim, frame);
	}

	inline public static function shake(duration: Float = 0, shakeInternal: Float = 0, offX: Float,
			offY: Float): zf.ef.Shake {
		final ef = zf.ef.Shake.alloc();
		ef.duration = duration;
		ef.shakeInterval = shakeInternal;
		ef.shakeRangeXMin = -offX;
		ef.shakeRangeXMax = offX;
		ef.shakeRangeYMin = -offY;
		ef.shakeRangeYMax = offY;
		return ef;
	}

	// ---- Expose zf.ef.Loop ---- //
	inline public static function loop(effect: zf.ef.Effect, loopCount: Int = -1): zf.ef.Effect {
		return zf.ef.Loop.loop(effect, loopCount);
	}

	// ---- Expose zf.ef.Alpha ---- //

	/**
		Create a effect that change the alpha

		@param alphaChange the amount of alpha to change
		@param duration the time it takes to change the alpha

		@return the effect
	**/
	inline public static function alphaChange(alphaChange: Float = 0, duration: Float = 0): zf.ef.Effect {
		return zf.ef.Alpha.change(alphaChange, duration);
	}

	/**
		Create a effect that change the alpha of an object over a duration

		@param targetAlpha the target alpha to reach
		@param duration the time it takes to reach the alpha

		@return the effect
	**/
	inline public static function alphaTo(targetAlpha: Float = 0, duration: Float = 0): zf.ef.Effect {
		return zf.ef.Alpha.alphaTo(targetAlpha, duration);
	}

	// ---- Expose zf.ef.Blink ---- //
	inline public static function blink(blinkCount: Null<Int> = -1, blinkSpeed: Float = -1): zf.ef.Effect {
		return zf.ef.Blink.blink(blinkCount, blinkSpeed);
	}

	inline public static function pop(scale: Float = .1, duration: Float = 1): zf.ef.Effect {
		return zf.ef.Pop.pop(scale, duration);
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

	/**
		Create a effect that move the object to a location and terminate

		@param x the target x position
		@param y the target y position
		@param duration the duration to move over
		@param terminate terminate the effect once it reaches the location
		@param resetOnRemove reset the object back to the original location when effect is removed.

		@return the effect
	**/
	inline public static function moveTo(x: Float, y: Float, duration: Float, terminate: Bool = true,
			resetOnRemove: Bool = false): zf.ef.Effect {
		return zf.ef.Move.moveTo(x, y, duration, terminate, resetOnRemove);
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
