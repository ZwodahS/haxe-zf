package zf.up;

/**
	@stage:stable

	Batch Update takes in a list of updates, run them together.
**/
class Batch extends Update {
	var updates: List<Updatable>;
	var finished: List<Updatable>;

	public function new(updates: Array<Updatable>) {
		super();
		this.updates = new List<Updatable>();
		this.finished = new List<Updatable>();
		for (u in updates) {
			if (Std.isOfType(u, Update)) {
				cast(u, Update).parent = this;
			}
			this.updates.add(u);
		}
	}

	override public function init(u: Updater) {
		super.init(updater);
		for (u in this.updates) {
			u.init(updater);
		}
	}

	override public function update(dt: Float) {
		final done: Array<Updatable> = [];
		for (u in this.updates) {
			u.update(dt);
			if (u.isDone()) done.push(u);
		}

		for (u in done) {
			this.updates.remove(u);
			this.finished.add(u);
			u.onFinish();
		}
	}

	override public function isDone(): Bool {
		return this.updates.length == 0;
	}

	override public function onRemoved() {
		super.onRemoved();
		for (u in this.updates) {
			u.onRemoved();
		}
		for (u in this.finished) {
			u.onRemoved();
		}
	}

	/**
		override the with method since I can just add it to my current list
	**/
	override public function with(u: Updatable): Update {
		this.updates.push(u);
		return this;
	}
}
