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
	var conf: WaitConf;

	public function new(conf: WaitConf) {
		super(conf);
		this.conf = conf;
		reset();
	}

	override function update(dt: Float): Bool {
		this.elapsed += dt;
		return this.conf.duration <= elapsed;
	}

	override function reset() {
		this.elapsed = 0;
	}

	override public function clone(): Wait {
		return new Wait(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		return this;
	}
}
