package zf.effects;

typedef MoveEffectConf = {
	> Effect.EffectConf,

	public var ?moveAmount: Point2f;
	public var ?moveFunction: (Float, Point2f) -> Point2f;
	public var ?duration: Float;

	// terminate after the move completes
	public var ?terminate: Bool; // default true
	// reset after removal
	public var ?resetOnRemove: Bool; // default false
}

/**
	@stage:stable
	Effect that change the position of an object.

	There were different ways to use this.
	1. terminate true + resetOnRemove false
	Animation: move the object by an amount and terminate afterward
	2. terminate false + resetOnRemove true
	Effect: hold the object by an amount, and return back to the object to the original amount.
**/
class MoveEffect extends Effect {
	public var conf: MoveEffectConf;

	var object: h2d.Object;

	var delta: Float = 0;

	var moveAmount: Point2f;
	var movedAmount: Point2f;
	var moveFunction: (Float, Point2f) -> Point2f;

	/**
		@param object the object
		@param conf the configuration
	**/
	public function new(object: h2d.Object, conf: MoveEffectConf) {
		super(conf);
		this.conf = conf;
		this.object = object;
		defaultConf(conf);

		this.moveAmount = conf.moveAmount;
		this.movedAmount = [0, 0];

		if (conf.moveFunction != null) {
			this.moveFunction = conf.moveFunction;
		} else {
			this.moveFunction = (delta, m) -> {
				m.x = delta / conf.duration * this.moveAmount.x;
				m.y = delta / conf.duration * this.moveAmount.y;
				return m;
			}
		}
		this.reset();
	}

	override function reset() {
		super.reset();
		this.movedAmount.x = 0;
		this.movedAmount.y = 0;
		this.delta = 0;
	}

	function defaultConf(conf: MoveEffectConf) {
		if (conf.moveFunction == null && conf.moveAmount == null) conf.moveAmount = [0, 0];
		if (conf.duration == null) conf.duration = 0;
		if (conf.terminate == null) conf.terminate = true;
		if (conf.resetOnRemove == null) conf.resetOnRemove = false;
	}

	override public function update(dt: Float): Bool {
		if (this.delta >= conf.duration) return this.conf.terminate;
		this.delta += dt;
		if (this.delta >= conf.duration) this.delta = conf.duration;

		this.object.x -= this.movedAmount.x; // remove the moved amount first
		this.object.y -= this.movedAmount.y;

		this.moveFunction(this.delta, this.movedAmount);

		this.object.x += this.movedAmount.x;
		this.object.y += this.movedAmount.y;

		return false;
	}

	override public function onEffectRemove() {
		if (this.conf.resetOnRemove == true) {
			this.object.x -= this.movedAmount.x;
			this.object.y -= this.movedAmount.y;
		}
	}
}
