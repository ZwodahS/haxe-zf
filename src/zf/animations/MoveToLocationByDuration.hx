package zf.animations;

class MoveToLocationByDuration extends Animation {
    var object: Positionable;
    var start: Point2f;
    var end: Point2f;
    var duration: Float;
    var delta: Float;
    var step: Point2f;

    var init = false;

    public function new(object: Positionable, position: Point2f, duration: Float) {
        super();
        this.object = object;
        this.end = position;
        this.duration = duration;
        this.delta = 0;
    }

    override public function isDone(): Bool {
        return this.delta >= this.duration;
    }

    function initSteps() {
        // delay this init for chain, or the position will be based on when it was constructed and not
        // when the animation start.
        this.start = [this.object.x, this.object.y];
        this.step = (this.end - this.start) * (1 / duration);
        this.init = true;
    }

    override public function update(dt: Float) {
        if (!this.init) initSteps();
        this.delta += dt;
        if (this.delta > this.duration) this.delta = this.duration;
        var currentPosition = this.start + (this.step * this.delta);
        this.object.x = currentPosition.x;
        this.object.y = currentPosition.y;
    }
}
