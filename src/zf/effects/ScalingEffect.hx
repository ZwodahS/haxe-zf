package zf.effects;

typedef ScalingEffectConf = {
	public var ?minScale: Float;
	public var ?maxScale: Float;
	public var ?cycleDuration: Float; // how long it takes to go from min to max and back
}

/**
	@stage:unstable

	Scale and object to min and max with a cycle
**/
class ScalingEffect extends Effect {
	public var conf: ScalingEffectConf;

	public var dt: Float = 0;

	var scaleDiff: Float;
	var halfDuration: Float;

	public function new(object: h2d.Object, conf: ScalingEffectConf) {
		super(object);
		this.conf = conf;
		if (this.conf.minScale == null) this.conf.minScale = 1.;
		if (this.conf.maxScale == null) this.conf.maxScale = 1.;
		if (this.conf.cycleDuration == null) this.conf.cycleDuration = 1.;
		this.scaleDiff = this.conf.maxScale - this.conf.minScale;
		this.halfDuration = this.conf.cycleDuration / 2;
		// we will first set the object scale to min straight away
		this.object.scaleX = this.conf.minScale;
		this.object.scaleY = this.conf.maxScale;
	}

	override function update(dt: Float): Bool {
		this.dt += dt;
		this.dt = this.dt % this.conf.cycleDuration;
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
}
