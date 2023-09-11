package zf.effects;

typedef ChainConf = {
	> Effect.EffectConf,
	public var ?loop: Bool; // default true
	public var ?onFinish: Void -> Void;
}

/**
	@stage:unstable

	Chain Update takes in a list of effect and run once after another.
**/
class Chain extends Effect {
	var currentIndex: Int = 0;
	var effects: Array<Effect>;
	var loop: Bool = true;
	var conf: ChainConf;

	public function new(effects: Array<Effect>, conf: ChainConf) {
		super(conf);
		this.effects = effects;
		this.conf = conf;
		for (effect in effects) {
			effect.ownerEffect = this;
		}
		if (conf.loop != null) this.loop = conf.loop;
	}

	override function update(dt: Float): Bool {
		if (this.currentIndex >= this.effects.length) return true;
		final done = this.effects[this.currentIndex].update(dt);
		if (done == true) {
			this.currentIndex += 1;
			if (this.currentIndex >= this.effects.length) {
				if (this.loop == false) {
					if (this.conf.onFinish != null) this.conf.onFinish();
					return true;
				}
				reset();
			}
		}
		return false;
	}

	override function reset() {
		for (effect in this.effects) effect.reset();
		this.currentIndex = 0;
	}

	override public function copy(): Chain {
		var effects: Array<Effect> = [];
		for (e in this.effects) {
			effects.push(e.copy());
		}
		var chain = new Chain(effects, Reflect.copy(this.conf));
		return chain;
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		for (effect in this.effects) {
			effect.applyTo(object, copy);
		}
		return this;
	}
}
