package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Chain extends Effect {
	@:dispose var currentIndex: Int = 0;
	@:dispose("all") var effects: Array<Effect>;

	function new() {
		super();
	}

	override function update(dt: Float): Bool {
		if (this.currentIndex >= this.effects.length) return true;

		final done = this.effects[this.currentIndex].update(dt);

		if (done == true) {
			this.effects[this.currentIndex].onEffectCompleted();
			this.currentIndex += 1;
			if (this.currentIndex >= this.effects.length) return true;
		}
		return false;
	}

	override function restart() {
		for (effect in this.effects) effect.restart();
		this.currentIndex = 0;
	}

	override public function clone(): Chain {
		final effects: Array<Effect> = [];
		for (e in this.effects) {
			effects.push(e.clone());
		}
		return Chain.chain(effects);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		final e = super.applyTo(object, copy, updater, whenDone);
		if (copy == true) return e;

		for (effect in this.effects) {
			effect.applyTo(object);
		}
		return e;
	}

	public static function chain(effects: Array<Effect>): Chain {
		final chain = Chain.alloc();

		chain.effects = effects;
		for (effect in effects) {
			effect.ownerEffect = chain;
		}

		return chain;
	}
}
