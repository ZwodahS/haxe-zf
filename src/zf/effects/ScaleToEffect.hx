package zf.effects;

typedef ScaleToEffectConf = {
	> Effect.EffectConf,

	public var ?scaleXTo: Float;
	public var ?scaleYTo: Float;
	public var ?duration: Float;
}

class ScaleToEffect extends Effect {
	var object: h2d.Object;
	var conf: ScaleToEffectConf;

	var duration: Float;
	var startScaleX: Float;
	var startScaleY: Float;

	var init: Bool = false;

	public function new(conf: ScaleToEffectConf) {
		super(conf);
		defaultConf(conf);
		this.conf = conf;
		this.duration = conf.duration;
	}

	function defaultConf(conf: ScaleToEffectConf) {
		if (conf.duration == null) conf.duration = 1;
	}

	override function update(dt: Float) {
		if (this.object == null || this.duration <= 0) return true;

		if (this.init == false) {
			this.startScaleX = this.object.scaleX;
			this.startScaleY = this.object.scaleY;
			this.init = true;
		}

		this.duration -= dt;
		if (this.duration < 0) this.duration = 0;

		final f = (this.conf.duration - this.duration) / this.conf.duration;
		if (this.conf.scaleXTo != null) {
			this.object.scaleX = this.startScaleX + ((this.conf.scaleXTo - this.startScaleX) * f);
		}

		if (this.conf.scaleYTo != null) {
			this.object.scaleY = this.startScaleY + ((this.conf.scaleYTo - this.startScaleY) * f);
		}

		return this.duration <= 0;
	}

	override public function clone(): ScaleToEffect {
		return new ScaleToEffect(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		this.object = object;
		return this;
	}
}
