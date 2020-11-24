package zf.animations;

/**
    Wait Animation just wait for a duration before finishing
**/
class Wait extends Animation {
    var elapsed: Float = 0;
    var duration: Float;

    public function new(duration: Float) {
        super();
        this.duration = duration;
    }

    override public function isDone(): Bool {
        return this.duration <= elapsed;
    }

    override public function update(dt: Float) {
        this.elapsed += dt;
    }
}
