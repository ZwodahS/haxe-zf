package common.animations;

class Func extends Animation {
    var isCompleted: Bool = false;

    var func: Void->Void;

    public function new(f: Void->Void) {
        super();
        this.func = f;
    }

    override public function isDone(): Bool {
        return isCompleted;
    }

    override public function update(dt: Float) {
        if (this.isDone()) return;
        this.func();
        this.isCompleted = true;
    }
}
