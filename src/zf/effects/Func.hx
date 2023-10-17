package zf.effects;

typedef FuncConf = {
	> Effect.EffectConf,
	public var ?func: Void->Void;
	public var ?funcUntil: Float->Bool;
}

/**
	There are 2 way to use this.

	1. func - the function will be run once and stop after
	2. funcUntil - the function is run with dt until it returns true
**/
class Func extends Effect {
	var conf: FuncConf;
	var completed: Bool = false;

	public function new(conf: FuncConf) {
		super(conf);
		this.conf = conf;
		reset();
	}

	override function update(dt: Float): Bool {
		if (completed == true) return true;
		if (this.conf.func != null) {
			this.conf.func();
			this.completed = true;
			return true;
		} else if (this.conf.funcUntil != null) {
			final f = this.conf.funcUntil(dt);
			this.completed = f;
			return this.completed;
		}
		return true;
	}

	override function reset() {
		this.completed = false;
	}

	override public function copy(): Func {
		return new Func(this.conf);
	}

	override public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		final e = super.applyTo(object, copy);
		if (copy == true) return e;

		return this;
	}
}
