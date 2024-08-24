package zf.effects;

typedef BlinkEffectConf = {
	> Effect.EffectConf,

	/**
		if provided, the effect terminates after amount of blink
		each blink is a single switch, i.e. from visible to non-visible.

		even blink count means that the object will return to the same visible state.
	**/
	public var ?blinkCount: Int;

	/**
		How often to switch between the visible state
	**/
	public var ?blinkSpeed: Float;
}

class BlinkEffect extends Effect {
	var object: h2d.Object;
	var conf: BlinkEffectConf;

	var blinkCountLeft: Int = -1;
	var delta: Float = 0;

	public function new(conf: BlinkEffectConf) {
		super(conf);
		this.conf = conf;
		defaultConf(conf);
		reset();
		if (this.conf.blinkCount != null) this.blinkCountLeft = this.conf.blinkCount;
	}

	function defaultConf(conf: BlinkEffectConf) {
		if (conf.blinkSpeed == null) conf.blinkSpeed = 1;
	}

	override function reset() {
		super.reset();
	}

	override public function clone(): BlinkEffect {
		return new BlinkEffect(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		this.object = object;
		return this;
	}

	override public function update(dt: Float): Bool {
		this.delta += dt;
		if (delta >= this.conf.blinkSpeed) {
			delta -= this.conf.blinkSpeed;
			this.object.visible = !this.object.visible;
			if (this.blinkCountLeft > 0) this.blinkCountLeft -= 1;
		}

		return this.blinkCountLeft == 0;
	}
}
