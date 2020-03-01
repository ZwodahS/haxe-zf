
package common;

import haxe.ds.List;

/**
    Updater provide a simple mechanism for running updates until it is done
**/

interface Updatable {
    public function onStart(): Void;
    public function update(dt: Float): Void;
    public function onDestroy(): Void;
    public function isDone(): Bool;
}

class Update implements Updatable{
	public var func: (dt: Float) -> Bool;
	public var done: Bool;

    public function new(func: (dt: Float) -> Bool) {
        this.func = func;
        this.done = false;
    }

	public function onStart() {}
    public function isDone(): Bool { return this.done; }
    public function onDestroy() {}
    public function update(dt: Float) {
        if (this.done) { return; }
        this.done = this.func(dt);
    }

}

class Updater {

    var updates: List<Updatable>;

    public var count(get, null): Int;

    public function new() {
        this.updates = new List<Updatable>();
    }

    public function update(dt: Float) {
        for (u in updates) {
            u.update(dt);
        }
        this.updates = updates.filter(function(u: Updatable): Bool {
            return !u.isDone();
        });
    }

    public function runFunc(func: (dt: Float) -> Bool) {
        this.updates.push(new Update(func));
    }

    public function run(u: Updatable) {
        this.updates.push(u);
    }

    public function get_count(): Int {
        return this.updates.length;
    }
}

