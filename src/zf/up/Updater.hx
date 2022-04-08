package zf.up;

using zf.ds.ListExtensions;

/**
	Fri 13:08:05 08 Apr 2022
	- merged Animator from zf.animations -> Updater
	- move Updater into zf.up to make the updater more multi purpose.

	Also took the opportunity to rename and add new functionalities to the updater

	onFinish in run is also deprecated
**/
/**
	Manage "updates" and provide various wrapper for handling them.

	# Basic
	Updater runs Updatable, which is a typedef.
	typedef is used to make duck typing easier

	zf.up.Update is a generic parent class that defines all methods in Updatable.
	It also provide various useful chaining methods.

	Various animations are provided at zf.up.animations.
	New animations can be extending zf.up.Update.

	Although there isn't anything preventing this to be used as the main loop to run all
	the updates in a game indefinitely, it is not created for that purpose.

	It is also not a bad idea to have multiple Updater.
	For example, splitting animations from non-blocking animations is sometimes a good idea
	if you want to restrict inputs when certain animations are played.
**/
class Updater {
	var updates: List<Updatable>;

	/**
		return the number of updates currently in the updater
	**/
	public var count(get, null): Int;

	public function get_count(): Int {
		return this.updates.length;
	}

	/**
		return true if there are no updates, false otherwise
	**/
	public var idle(get, null): Bool;

	public function get_idle(): Bool {
		return this.updates.length == 0;
	}

	var onIdleHandlers: List<Void->Void>;

	public function new() {
		this.updates = new List<Updatable>();
		this.onIdleHandlers = new List<Void->Void>();
	}

	/**
		The main update loop. Call this every frame
	**/
	public function update(dt: Float) {
		if (this.updates.length == 0) return;
		final toFinish = new List<Updatable>();

		for (u in updates) {
			u.update(dt);
			if (u.isDone()) {
				toFinish.push(u);
			}
		}

		this.updates.inFilter(function(u: Updatable): Bool {
			return !u.isDone();
		});

		for (u in toFinish) {
			u.onFinish();
			u.onRemoved();
		}

		if (this.idle) {
			for (u in this.onIdleHandlers) {
				u();
			}
			this.onIdleHandlers.clear();
		}
	}

	/**
		Add a handler to handle when this animator became idle.
		This function will only be called once and will be remove after.
	**/
	public function onIdle(f: Void->Void) {
		this.onIdleHandlers.add(f);
	}

	/**
		Fri 16:29:28 08 Apr 2022
		deprecating onFinish.
	**/
	@:deprecated("onFinish param is deprecated. use whenDone instead")
	overload public extern inline function run(u: Updatable = null, onFinish: Void->Void = null): Update {
		return _run(u, null, onFinish);
	}

	@:deprecated("onFinish param is deprecated. use whenDone instead")
	overload public extern inline function run(updates: Array<Updatable> = null, onFinish: Void->Void = null): Update {
		return _run(null, updates, onFinish);
	}

	overload public extern inline function run(update: Updatable = null): Update {
		return _run(update, null);
	}

	overload public extern inline function run(updates: Array<Updatable> = null): Update {
		return _run(null, updates);
	}

	/**
		the main run function.
	**/
	@:native('run') @:noCompletion
	public function _run(u: Updatable = null, updates: Array<Updatable> = null, onFinish: Void->Void = null): Update {
		// handle the 2 different configurations
		if (u != null) {
			var up: Update = null;
			if (Std.isOfType(u, Update) == false) {
				// if the object is not a Update, then we wrap around it to make it a Update object.
				// this allow this function to return Update
				up = new UpdatableWrap(u);
			} else {
				up = cast(u, Update);
			}
			up.init(this);
			this.updates.push(up);
			if (onFinish != null) up.whenDone(onFinish);
			return up;
		} else if (updates != null) {
			final batch = new Batch(updates);
			batch.init(this);
			this.updates.push(batch);
			if (onFinish != null) batch.whenDone(onFinish);
			return batch;
		} else {
			return null;
		}
	}

	// ---- Additional run functions ---- //

	/**
		wait will wait for duration and run a function after it (if provided).
		this returns a Chain Update that can be used to add more update
	**/
	public function wait(duration: Float, func: Void->Void = null, funcWUpdate: Void->Updatable = null): Update {
		final updates: Array<Updatable> = [new Wait(duration)];
		if (func != null) {
			updates.push(new RunOnce(func));
		} else if (funcWUpdate != null) {
			updates.push(new RunOnce(funcWUpdate));
		}
		final chain = new Chain(updates);
		run(chain);
		return chain;
	}

	/**
		wait for a function to return true, then run another function
	**/
	public function waitFor(waitFunc: Void->Bool, func: Void->Void = null,
			funcWUpdate: Void->Updatable = null): Update {
		final updates: Array<Updatable> = [new WaitFor(waitFunc)];
		if (func != null) {
			updates.push(new RunOnce(func));
		} else if (funcWUpdate != null) {
			updates.push(new RunOnce(funcWUpdate));
		}
		final chain = new Chain(updates);
		run(chain);
		return chain;
	}

	public function chain(updates: Array<Updatable>): Chain {
		final chain = new Chain(updates);
		this.run(chain);
		return chain;
	}

	/**
		Stop a updatable and remove it from the updater.
	**/
	public function stop(u: Updatable): Bool {
		final removed = this.updates.remove(u);
		if (removed == true) u.onRemoved();
		return removed;
	}

	/**
		Remove and clear all the updates in the Updater
	**/
	public function clear() {
		for (u in this.updates) {
			u.onRemoved();
		}
		this.updates.clear();
	}
}
