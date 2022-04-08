package zf.up;

/**
	Chain Update takes in a list of updates, and run them one after another
**/
class Chain extends Update {
	var currentIndex: Int;
	var updates: Array<Updatable>;

	public function new(updates: Array<Updatable>) {
		super();
		this.currentIndex = 0;
		this.updates = [];
		for (u in updates) {
			if (Std.isOfType(u, Update)) {
				cast(u, Update).parent = this;
			}
			this.updates.push(u);
		}
	}

	override public function init(updater: Updater) {
		super.init(updater);
		for (u in this.updates) {
			u.init(updater);
		}
	}

	override public function update(dt: Float) {
		if (this.isDone()) return;
		this.updates[this.currentIndex].update(dt);
		if (this.updates[this.currentIndex].isDone()) {
			this.updates[this.currentIndex].onFinish();
			this.currentIndex++;
		}
	}

	override public function isDone(): Bool {
		return this.currentIndex >= this.updates.length;
	}

	override public function onRemoved() {
		super.onRemoved();
		for (u in this.updates) {
			u.onRemoved();
		}
	}

	/**
		Override the then method to just add the update into this Chain
	**/
	override public function then(update: Updatable): Update {
		this.updates.push(update);
		return this;
	}

	/**
		Override the then method to just add the update into this Chain
	**/
	override public function wait(duration: Float): Update {
		this.updates.push(new Wait(duration));
		return this;
	}

	/**
		Override the then method to just add the update into this Chain
	**/
	override public function waitFor(func: Void->Bool): Update {
		this.updates.push(new WaitFor(func));
		return this;
	}
}
