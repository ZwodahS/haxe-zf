package zf.effects;

typedef FuncConf = {
	> Effect.EffectConf,
	public var func: Void->Void;
}

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
		this.completed = true;
		this.conf.func();
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
