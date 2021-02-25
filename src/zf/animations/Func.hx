package zf.animations;

class Func extends Animation {
	var isCompleted: Bool = false;

	var func: Float->Bool;

	public function new(f: Float->Bool) {
		super();
		this.func = f;
	}

	override public function isDone(): Bool {
		return isCompleted;
	}

	override public function update(dt: Float) {
		if (this.isDone()) return;
		this.isCompleted = this.func(dt);
	}
}
