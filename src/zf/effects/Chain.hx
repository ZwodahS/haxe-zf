package zf.effects;

typedef ChainConf = {
	> Effect.EffectConf,
	public var ?loop: Bool; // default true
}

/**
	@stage:unstable

	Chain Update takes in a list of effect and run once after another.
**/
class Chain extends Effect {
	var currentIndex: Int = 0;
	var effects: Array<Effect>;
	var loop: Bool = true;

	public function new(effects: Array<Effect>, conf: ChainConf) {
		super(conf);
		this.effects = effects;
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
				if (this.loop == false) return true;
				reset();
			}
		}
		return false;
	}

	override function reset() {
		for (effect in this.effects) effect.reset();
		this.currentIndex = 0;
	}
}
