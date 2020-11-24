package zf.animations;

class ScaleTo extends Animation {
    var object: Scalable;
    var scaleTo: Point2f;
    var scaleSpeed: Point2f;

    public function new(object: Scalable, scaleTo: Point2f, speeds: Point2f = null, speed: Float = 1) {
        super();
        this.object = object;
        this.scaleTo = scaleTo;
        this.scaleSpeed = speeds != null ? speeds : [speed, speed];
    }

    override public function isDone(): Bool {
        return this.scaleTo == [this.object.scaleX, this.object.scaleY];
    }

    override public function update(dt: Float) {
        if (this.isDone()) {
            return;
        }

        if (this.object.scaleX != this.scaleTo.x) {
            var direction = this.object.scaleX > this.scaleTo.x ? -1 : 1;
            var scaleX = this.scaleSpeed.x * dt * direction;
            if (scaleX < 0) {
                this.object.scaleX = Math.max(this.object.scaleX + scaleX, this.scaleTo.x);
            } else {
                this.object.scaleX = Math.min(this.object.scaleX + scaleX, this.scaleTo.x);
            }
        }

        if (this.object.scaleY != this.scaleTo.y) {
            var direction = this.object.scaleY > this.scaleTo.y ? -1 : 1;
            var scaleY = this.scaleSpeed.y * dt * direction;
            if (scaleY < 0) {
                this.object.scaleY = Math.max(this.object.scaleY + scaleY, this.scaleTo.y);
            } else {
                this.object.scaleY = Math.min(this.object.scaleY + scaleY, this.scaleTo.y);
            }
        }
    }
}
