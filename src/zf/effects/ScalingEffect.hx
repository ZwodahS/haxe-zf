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
	public var conf: ScalingEffectConf;

	var object: h2d.Object;

	public var dt: Float = 0;

	var scaleDiff: Float;
	var halfDuration: Float;

	var numCycleLeft: Int = -1;

	/**
		@param object the object to scale
		@param conf the configuration effect
	**/
	public function new(object: h2d.Object, conf: ScalingEffectConf) {
		super(conf);
		this.conf = conf;
		this.object = object;

		if (this.conf.minScale == null) this.conf.minScale = 1.;
		if (this.conf.maxScale == null) this.conf.maxScale = 1.;
		if (this.conf.cycleDuration == null) this.conf.cycleDuration = 1.;
		this.scaleDiff = this.conf.maxScale - this.conf.minScale;
		this.halfDuration = this.conf.cycleDuration / 2;
		// we will first set the object scale to min straight away
		this.reset();
	}

	override function update(dt: Float): Bool {
		if (this.numCycleLeft == 0) return true;
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
		this.object.scaleX = this.conf.minScale;
		this.object.scaleY = this.conf.minScale;
		if (this.conf.numCycle != null) this.numCycleLeft = this.conf.numCycle;
	}
}
