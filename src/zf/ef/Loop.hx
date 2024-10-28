package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Loop extends Effect {
	@:dispose var loopCount: Int = -1;
	@:dispose var currLoop: Int = 0;

	@:dispose var effect: Effect;

	function new() {
		super();
	}

	override function update(dt: Float): Bool {
		final done = this.effect.update(dt);
		if (done == true) {
			this.onEffectCompleted();
			this.currLoop += 1;
		}
		if (loopCount != -1 && this.currLoop >= loopCount) return true;
		if (done == true) this.effect.restart();
		return false;
	}

	override function restart() {
		effect.restart();
		this.currLoop = 0;
	}

	override public function clone(): Loop {
		return Loop.loop(this.effect.clone(), this.loopCount);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		final e = super.applyTo(object, copy, updater, whenDone);
		if (copy == true) return e;

		this.effect.applyTo(object);

		return e;
	}

	public static function loop(effect: Effect, loopCount: Int = -1): Loop {
		final loop = Loop.alloc();

		loop.effect = effect;
		loop.loopCount = loopCount;
		effect.ownerEffect = loop;

		return loop;
	}
}
