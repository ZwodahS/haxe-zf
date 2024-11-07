package zf.ef;

/**
	A effect that change the position of an object
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Move extends Effect {
	// ---- Configuration ---- //

	/**
		The duration to apply the effect
	**/
	@:dispose var duration: Float = 0;

	/**
		The function to apply
	**/
	@:dispose var moveFunction: (Float, Point2f) -> Point2f = null;

	/**
		Terminate the effect once it is complete.
	**/
	@:dispose var terminate: Bool = true;

	/**
		Undo the moved amount when the effect is completed.
	**/
	@:dispose var resetOnRemove: Bool = true;

	// ---- State ---- //
	@:dispose var delta: Float = 0;
	@:dispose var movedAmount: Point2f;

	function new() {
		super();
	}

	override public function clone(): Move {
		final object = Move.alloc();

		object.duration = this.duration;
		object.moveFunction = this.moveFunction;
		object.terminate = this.terminate;
		object.resetOnRemove = this.resetOnRemove;

		return object;
	}

	override public function restart() {
		if (this.object != null) {
			this.object.x -= this.movedAmount.x;
			this.object.y -= this.movedAmount.y;
		}

		this.movedAmount.x = 0;
		this.movedAmount.y = 0;
		this.duration = 0;
	}

	override public function update(dt: Float) {
		if (this.duration != -1 && this.delta >= this.duration) return this.terminate;
		this.delta += dt;
		if (this.duration != -1 && this.delta >= this.duration) this.delta = this.duration;

		this.object.x -= this.movedAmount.x;
		this.object.y -= this.movedAmount.y;

		this.movedAmount = this.moveFunction(this.delta, this.movedAmount);

		this.object.x += this.movedAmount.x;
		this.object.y += this.movedAmount.y;

		return false;
	}

	/**
		private alloc function.
		This should never be used.
	**/
	static function alloc(): Move {
		final object = Move.__alloc__();

		object.movedAmount = Point2f.alloc();

		return object;
	}

	public static function moveByAmount(x: Float, y: Float, duration: Float, terminate: Bool = true,
			resetOnRemove: Bool = false): Move {
		final func = (delta: Float, pt: Point2f) -> {
			pt.x = delta / duration * x;
			pt.y = delta / duration * y;
			return pt;
		}
		return moveByFunc(func, duration, terminate, resetOnRemove);
	}

	public static function moveByFunc(mFunc: (Float, Point2f) -> Point2f, duration: Float, terminate: Bool = true,
			resetOnRemove: Bool = false): Move {
		final object = alloc();

		object.moveFunction = mFunc;
		object.duration = duration;
		object.terminate = terminate;
		object.resetOnRemove = resetOnRemove;

		return object;
	}

	override public function onEffectRemoved() {
		super.onEffectRemoved();
		if (this.resetOnRemove == true && this.object != null && this.movedAmount != null) {
			this.object.x -= this.movedAmount.x;
			this.object.y -= this.movedAmount.y;
		}
	}
}
