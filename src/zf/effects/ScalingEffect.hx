package zf.effects;

typedef ScalingEffectConf = {
	> Effect.EffectConf,
	public var ?minScale: Float;
	public var ?maxScale: Float;
	public var ?cycleDuration: Float; // how long it takes to go from min to max and back
	public var ?numCycle: Int; // if provided, it will only scale for a number of cycle before completing
}

/**
	@stage:stable

	Scale and object to min and max with a cycle
**/
class ScalingEffect extends Effect {
	var conf: ScalingEffectConf;
	var object: h2d.Object;

	var scaleDiff: Float;
	var halfDuration: Float;

	var dt: Float = 0;
	var numCycleLeft: Int = -1;

	/**
		@param object the object to scale
		@param conf the configuration effect
	**/
	public function new(conf: ScalingEffectConf) {
		super(conf);
		defaultConf(conf);
		this.conf = conf;

		// precompute some values
		this.scaleDiff = this.conf.maxScale - this.conf.minScale;
		this.halfDuration = this.conf.cycleDuration / 2;
		this.reset();
	}

	function defaultConf(conf: ScalingEffectConf) {
		if (conf.minScale == null) conf.minScale = 1.;
		if (conf.maxScale == null) conf.maxScale = 1.;
		if (conf.cycleDuration == null) conf.cycleDuration = 1.;
	}

	override function update(dt: Float): Bool {
		if (this.object == null || this.numCycleLeft == 0) return true;
		this.dt += dt;
		if (this.dt >= this.conf.cycleDuration) {
			this.numCycleLeft -= 1;
			if (this.numCycleLeft == 0) {
				this.object.scaleX = 1;
				this.object.scaleY = 1;
				return true;
			}
			this.dt = this.dt % this.conf.cycleDuration;
		}
		// update scale
		if (this.dt > this.halfDuration) { // scaling up
			this.object.scaleX = this.conf.minScale + (scaleDiff * (this.dt / halfDuration));
			this.object.scaleY = this.conf.minScale + (scaleDiff * (this.dt / halfDuration));
		} else { // scaling down
			this.object.scaleX = this.conf.minScale
				+ (scaleDiff - (scaleDiff * ((this.dt - halfDuration) / halfDuration)));
			this.object.scaleY = this.conf.minScale
				+ (scaleDiff - (scaleDiff * ((this.dt - halfDuration) / halfDuration)));
		}
		return false;
	}

	override function reset() {
		if (this.conf.numCycle != null) this.numCycleLeft = this.conf.numCycle;
	}

	override public function clone(): ScalingEffect {
		return new ScalingEffect(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		this.object = object;
		this.object.scaleX = this.conf.minScale;
		this.object.scaleY = this.conf.minScale;
		return this;
	}
}
