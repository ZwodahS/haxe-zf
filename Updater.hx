
package common;

import haxe.ds.List;

/**
    Updater provide a simple mechanism for running updates until it is done
**/

interface Updatable {
    public function finish(): Void; // call when the update ends
    public function update(dt: Float): Void;
    public function isDone(): Bool;
}

class Update implements Updatable{
	public var func: (dt: Float) -> Bool;
    public var onFinish: () -> Void;
	public var done: Bool;

    public function new(func: (dt: Float) -> Bool, onFinish: () -> Void) {
        this.func = func;
        this.done = false;
        this.onFinish = onFinish;
    }

    public function finish() {
        if (this.onFinish != null) {
            this.onFinish();
        }
    }
    public function isDone(): Bool { return this.done; }
    public function update(dt: Float) {
        if (this.done) { return; }
        this.done = this.func(dt);
    }

}

class Updater {

    var updates: List<Updatable>;
    var toFinish: List<Updatable>;

    public var count(get, null): Int;

    public function new() {
        this.updates = new List<Updatable>();
        this.toFinish = new List<Updatable>();
    }

    public function update(dt: Float) {
        for (u in updates) {
            u.update(dt);
            if (u.isDone()) {
                this.toFinish.push(u);
            }
        }
        this.updates = updates.filter(function(u: Updatable): Bool {
            return !u.isDone();
        });
        for (u in this.toFinish) {
            u.finish();
        }
        this.toFinish.clear();
    }

    public function runFunc(func: (dt: Float) -> Bool, onFinish: () -> Void = null) {
        this.updates.push(new Update(func, onFinish));
    }

    public function run(u: Updatable) {
        this.updates.push(u);
    }

    public function get_count(): Int {
        return this.updates.length;
    }
}

