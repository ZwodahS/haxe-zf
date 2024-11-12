package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Batch extends Effect {
	@:dispose("all") var effects: Array<Effect>;
	@:dispose("set") var runningEffects: Array<Effect> = null;

	function new() {
		super();
	}

	override function update(dt: Float): Bool {
		final completed = [];
		for (effect in this.runningEffects) {
			if (effect.update(dt) == true) completed.push(effect);
		}
		for (effect in completed) {
			effect.onEffectCompleted();
			this.runningEffects.remove(effect);
		}
		if (this.runningEffects.length == 0) return true;
		return false;
	}

	override function restart() {
		for (effect in this.effects) effect.restart();
		this.runningEffects.clear();
		this.runningEffects.pushArray(this.effects);
	}

	override public function clone(): Batch {
		final effects: Array<Effect> = [];
		for (e in this.effects) {
			effects.push(e.clone());
		}
		return Batch.batch(effects);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		final e = super.applyTo(object, copy, updater, whenDone);
		if (copy == true) return e;

		for (effect in this.effects) {
			effect.applyTo(object);
		}
		this.runningEffects.pushArray(this.effects);
		return e;
	}

	public static function batch(effects: Array<Effect>): Batch {
		final batch = Batch.alloc();

		batch.effects = effects;
		for (effect in effects) {
			effect.ownerEffect = batch;
		}
		batch.runningEffects = [];

		return batch;
	}

	@:inheritDoc override public function with(effect: Effect): Batch {
		/**
			Override then in zf.ef.Effect to not create unnecessary object
		**/
		this.effects.push(effect);
		effect.ownerEffect = this;
		return this;
	}
}
