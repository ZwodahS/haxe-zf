package zf.animations;

class RunOnce extends Animation {
	var func: Void->Void;
	var ran: Bool = false;

	public function new(f: Void->Void) {
		super();
		this.func = f;
	}

	override public function isDone(): Bool {
		return this.ran;
	}

	override public function update(dt: Float) {
		this.func();
		this.ran = true;
	}
}
