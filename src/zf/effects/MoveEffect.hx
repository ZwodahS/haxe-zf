package zf.effects;

typedef MoveEffectConf = {
	> Effect.EffectConf,

	public var ?moveAmount: Point2f;
	public var ?moveFunction: (Float, Point2f) -> Point2f;
	public var ?duration: Float;
}

/**
	@stage:stable

	Move the object and move itself afterward.

	This effect will terminate once the move amount is reached.
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
	}

	override public function update(dt: Float): Bool {
		if (this.delta >= conf.duration) return true;
		this.delta += dt;
		if (this.delta >= conf.duration) this.delta = conf.duration;

		this.object.x -= this.movedAmount.x; // remove the moved amount first
		this.object.y -= this.movedAmount.y;

		this.moveFunction(this.delta, this.movedAmount);

		this.object.x += this.movedAmount.x;
		this.object.y += this.movedAmount.y;

		return false;
	}
}
