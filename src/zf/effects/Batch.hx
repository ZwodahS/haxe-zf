package zf.effects;

typedef BatchConf = {
	> Effect.EffectConf,
	public var ?loop: Bool; // default true
}

/**
	@stage:unstable

	Batch takes in a list of effect and run them together.
	Once all effects is finished, this will be considered as finished.

	When Batch finish, and loop is true, we will restart.
	If loop is false, we will return true in update
**/
class Batch extends Effect {
	var currentIndex: Int = 0;
	var effects: Array<Effect>;
	var runningEffects: Array<Effect>;
	var loop: Bool = true;

	public function new(effects: Array<Effect>, conf: BatchConf) {
		super(conf);
		this.effects = effects;
		this.runningEffects = [];
		for (effect in effects) {
			effect.ownerEffect = this;
			this.runningEffects.push(effect);
		}
		if (conf.loop != null) this.loop = conf.loop;
	}

	override function update(dt: Float): Bool {
		final toBeRemove = [];
		for (effect in this.runningEffects) {
			if (effect.update(dt) == true) toBeRemove.push(effect);
		}
		for (effect in toBeRemove) this.runningEffects.remove(effect);
		if (this.runningEffects.length == 0) {
			if (loop == false) return true;
			reset();
		}
		return false;
	}

	override function reset() {
		for (effect in this.effects) effect.reset();
		this.runningEffects.clear();
		this.runningEffects.pushArray(this.effects);
	}
}
