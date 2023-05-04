package zf.effects;

typedef AlphaEffectConf = {
	> Effect.EffectConf,

	public var ?alphaChange: Float;
	public var ?duration: Float;
}

class AlphaEffect extends Effect {
	var conf: AlphaEffectConf;
	var object: h2d.Object;

	var delta: Float = 0;
	var changed: Float = 0;

	/**
		@param object the object
		@param conf the configuration
	**/
	public function new(conf: AlphaEffectConf) {
		super(conf);
		this.conf = conf;
		defaultConf(conf);
		reset();
	}

	function defaultConf(conf: AlphaEffectConf) {
		if (conf.duration == null) conf.duration = 0;
		if (conf.alphaChange == null) conf.alphaChange = 0;
	}

	override public function update(dt: Float): Bool {
		if (this.delta >= conf.duration) return true;
		this.delta += dt;
		if (this.delta >= conf.duration) this.delta = conf.duration;

		this.object.alpha -= this.changed;
		this.changed = this.delta / this.conf.duration * conf.alphaChange;
		this.object.alpha += this.changed;

		return false;
	}

	override function reset() {
		super.reset();
		this.delta = 0;
		this.changed = 0;
	}

	override public function copy(): AlphaEffect {
		return new AlphaEffect(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		this.object = object;
		return this;
	}
}
