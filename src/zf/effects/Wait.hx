package zf.effects;

typedef WaitConf = {
	> Effect.EffectConf,
	public var duration: Float;
}

/**
	@stage:stable

	Wait just wait for a duration before finishing
**/
class Wait extends Effect {
	var elapsed: Float = 0;
	var duration: Float = 0;

	public function new(conf: WaitConf) {
		super(conf);
		this.duration = conf.duration;
	}

	override function update(dt: Float): Bool {
		this.elapsed += dt;
		return this.duration <= elapsed;
	}

	override function reset() {
		this.elapsed = 0;
	}
}
