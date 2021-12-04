package zf.animations;

/**
	WaitFor animation wait for a function to return true before finishing
	Because this runs on every update, the waitFunc should be something light.
**/
class WaitFor extends Animation {
	public function new(waitFor: Void->Bool = null) {
		super();
		if (waitFor != null) this.waitFunc = waitFor;
	}

	override public function isDone(): Bool {
		return this.waitFunc();
	}

	dynamic public function waitFunc(): Bool {
		return true;
	}
}
