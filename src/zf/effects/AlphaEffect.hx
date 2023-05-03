package zf.effects;

typedef AlphaEffectConf = {
	> Effect.EffectConf,

	public var ?alphaChange: Float;
	public var ?duration: Float;
}

class AlphaEffect extends Effect {
	public var conf: AlphaEffectConf;

	var object: h2d.Object;

	var delta: Float = 0;
	var changed: Float = 0;

	/**
		@param object the object
		@param conf the configuration
	**/
	public function new(object: h2d.Object, conf: AlphaEffectConf) {
		super(conf);
		this.conf = conf;
		this.object = object;
		defaultConf(conf);
	}

	override function reset() {
		super.reset();
		this.delta = 0;
		this.changed = 0;
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
}
