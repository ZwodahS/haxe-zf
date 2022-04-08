package zf.up;

class UpdatableWrap extends Update {
	var updatable: Updatable;

	public function new(update: Updatable) {
		super();
		this.updatable = update;
	}

	override public function init(updater: Updater) {
		super.init(updater);
		this.updatable.init(updater);
	}

	override public function update(dt: Float) {
		this.updatable.update(dt);
	}

	override public function isDone(): Bool {
		return this.updatable.isDone();
	}

	override public function onFinish(): Void {
		return this.updatable.onFinish();
	}

	override public function onRemoved() {
		super.onRemoved();
		this.updatable.onRemoved();
	}
}
