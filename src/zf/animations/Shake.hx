package zf.animations;

import zf.Point2f;

class Shake extends Animation {
    var object: Positionable;
    var duration: Float;
    var amount: Float;
    var currentOffset: Point2f;

    public function new(object: Positionable, amount: Float, duration: Float) {
        super();
        this.object = object;
        this.duration = duration;
        this.currentOffset = [0, 0];
        this.amount = amount;
    }

    override public function isDone(): Bool {
        return this.duration <= 0;
    }

    override public function update(dt: Float) {
        this.duration -= dt;

        var position: Point2f = new Point2f(this.object.x, this.object.y)
            - currentOffset;
        if (duration <= 0) {
            this.currentOffset = [.0, .0];
        } else {
            this.currentOffset = [
                (Random.int(0, 100) / 100 * this.amount * 2) - this.amount,
                (Random.int(0, 100) / 100 * this.amount * 2) - this.amount,
            ];
        }
        position += this.currentOffset;
        this.object.x = position.x;
        this.object.y = position.y;
    }
}
