package zf.up;

/**
	@stage:stable

	A generic run once update that only run once.

	Optionally, if the function returns a update, it will be run in place.
**/
class RunOnce extends Update {
	var func: Void->Void;
	var funcWithUpdate: Void->Updatable;
	var ran: Bool = false;

	var inPlaceUpdate: Updatable;

	public function new(f: Void->Void = null, fwu: Void->Updatable = null) {
		super();
		this.func = f;
		this.funcWithUpdate = fwu;
	}

	override public function isDone(): Bool {
		if (this.inPlaceUpdate != null) return this.inPlaceUpdate.isDone();
		return this.ran;
	}

	override public function update(dt: Float) {
		if (this.inPlaceUpdate != null) return this.inPlaceUpdate.update(dt);
		if (this.func != null) {
			this.func();
		} else if (this.funcWithUpdate != null) {
			this.inPlaceUpdate = this.funcWithUpdate();
			if (this.inPlaceUpdate != null) {
				this.inPlaceUpdate.init(this.updater);
			}
		}
		this.ran = true;
	}

	override public function onFinish() {
		super.onFinish();
		if (this.inPlaceUpdate != null) this.inPlaceUpdate.onFinish();
	}

	override public function onRemoved() {
		super.onFinish();
		if (this.inPlaceUpdate != null) this.inPlaceUpdate.onRemoved();
	}
}
