package zf.up;

/**
	@stage:stable

	A generic parent class for all Updatable and provide various useful method
**/
class Update {
	var parent: Update;
	var updater: Updater;
	var onFinishes: Array<Void->Void>;

	public function new() {
		this.onFinishes = [];
	}

	public function isDone(): Bool {
		return false;
	}

	public function update(dt: Float) {}

	public function init(u: Updater) {
		this.updater = u;
	}

	public function onRemoved() {
		this.updater = null;
	}

	public function onFinish() {
		for (f in this.onFinishes) {
			f();
		}
	}

	public function stop(): Bool {
		if (this.parent != null) return this.parent.stop();
		if (this.updater == null) return false;
		return this.updater.stop(this);
	}

	// ---- Various useful chaining method ---- //

	/**
		Run another update after this
	**/
	public function then(update: Updatable): Update {
		final updates: Array<Updatable> = [this, update];
		return new Chain(updates);
	}

	/**
		Run a function after this
	**/
	public function thenRun(func: Void->Void = null, funcWithUpdate: Void->Updatable = null): Update {
		if (func == null && funcWithUpdate == null) return this;
		final runOnce = new RunOnce(func, funcWithUpdate);
		return this.then(runOnce);
	}

	/**
		Run another update together with this update
	**/
	public function with(update: Updatable): Update {
		final updates: Array<Updatable> = [this, update];
		return new Batch(updates);
	}

	public function withRun(func: Void->Void = null, funcWithUpdate: Void->Updatable = null): Update {
		if (func == null && funcWithUpdate == null) return this;
		final runOnce = new RunOnce(func, funcWithUpdate);
		return this.with(runOnce);
	}

	/**
		Wait after running this update
	**/
	public function wait(duration: Float): Update {
		final updates: Array<Updatable> = [this, new Wait(duration)];
		return new Chain(updates);
	}

	/**
		Wait for a function to return true after this update
	**/
	public function waitFor(func: Void->Bool): Update {
		final updates: Array<Updatable> = [this, new WaitFor(func)];
		return new Chain(updates);
	}

	/**
		run a function after this update is done
	**/
	public function whenDone(onFinish: Void->Void): Update {
		if (onFinish == null) return this;
		this.onFinishes.push(onFinish);
		return this;
	}
}
