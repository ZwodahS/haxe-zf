package zf.ef;

/**
	There are 2 way to use this.

	1. func - the function will be run once and stop after
	2. funcUntil - the function is run with dt until it returns true
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Func extends Effect {
	@:dispose var func: Void->Void = null;
	@:dispose var funcUntil: Float->Bool = null;

	@:dispose var done: Bool = false;

	function new() {
		super();
	}

	override function update(dt: Float): Bool {
		if (this.done == true) return true;
		if (this.func != null) {
			this.func();
			this.done = true;
			return true;
		} else if (this.funcUntil != null) {
			this.done = this.funcUntil(dt);
			return this.done;
		}
		return true;
	}

	override function restart() {
		super.restart();
		this.done = false;
	}

	override public function clone(): Func {
		final effect = Func.alloc();

		effect.func = this.func;
		effect.funcUntil = this.funcUntil;

		return effect;
	}

	public static function run(f: Void->Void): Func {
		final effect = Func.alloc();

		effect.func = f;

		return effect;
	}

	public static function runUntil(f: Float->Bool): Func {
		final effect = Func.alloc();

		effect.funcUntil = f;

		return effect;
	}
}
