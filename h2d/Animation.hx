
package common.h2d;

import common.Updater;
import common.Point2f;
import common.MathUtils;

/**
  Animation provide the common "animation" for h2d.Objects
**/

class Animation implements Updatable {

    public var onFinish: () -> Void;

    public function new() {}
    public function finish() { if (this.onFinish != null) { onFinish(); }}
    public function isDone(): Bool { return true; }
    public function update(dt: Float) {}
}

class MoveToAnimation extends Animation {

    var object: h2d.Object;
    var position: Point2f;
    var speed: Point2f;

    public function new(object: h2d.Object, position: Point2f, speeds: Point2f = null, speed: Float = 1) {
        super();
        this.object = object;
        this.position = position;
        this.speed = speeds != null ? speeds : [ speed, speed ];
    }

    override public function isDone(): Bool { return this.position == [ this.object.x, this.object.y ]; }

    override public function update(dt: Float) {
        if (this.isDone()) { return; }

        if (this.object.x != this.position.x) {
            var direction = this.object.x > this.position.x ? -1 : 1;
            var moveX = this.speed.x * dt * direction;
            if (moveX < 0) {
                this.object.x = Math.max(this.object.x + moveX, this.position.x);
            } else {
                this.object.x = Math.min(this.object.x + moveX, this.position.x);
            }
        }

        if (this.object.y != this.position.y) {
            var direction = this.object.y > this.position.y ? -1 : 1;
            var moveY = this.speed.y * dt * direction;
            if (moveY < 0) {
                this.object.y = Math.max(this.object.y + moveY, this.position.y);
            } else {
                this.object.y = Math.min(this.object.y + moveY, this.position.y);
            }
        }

    }

}

class MoveByAnimation extends Animation {

    var object: h2d.Object;
    var amount: Point2f;
    var amountLeft: Point2f;
    var speed: Point2f;

    public function new(object: h2d.Object, moveAmount: Point2f, speeds: Point2f = null, speed: Float = 1) {
        super();
        this.object = object;
        this.amount = moveAmount.copy();
        this.amountLeft = moveAmount.copy();
        this.speed = speeds != null ? speeds : [ speed, speed ];
    }

    override public function isDone(): Bool { return (this.amountLeft.x == 0 && this.amountLeft.y == 0); }

    override public function update(dt: Float) {
        if (this.isDone()) { return; }

        var moveX = dt * this.speed.x * MathUtils.sign(this.amountLeft.x);
        if (moveX < 0) {
            moveX = Math.max(this.amountLeft.x, moveX);
        } else {
            moveX = Math.min(this.amountLeft.x, moveX);
        }
        this.amountLeft.x -= moveX;
        this.object.x += moveX;

        var moveY = dt * this.speed.y * MathUtils.sign(this.amountLeft.y);
        if (moveY < 0) {
            moveY = Math.max(this.amountLeft.y, moveY);
        } else {
            moveY = Math.min(this.amountLeft.y, moveY);
        }
        this.amountLeft.y -= moveY;
        this.object.y += moveY;
    }

}

class Animator extends common.Updater { // extends the Updater since most of it is the same

    public function new() {
        super();
    }

    // mirrors MoveToAnimation constructor
    public function moveTo(
            object: h2d.Object, position: Point2f, speeds: Point2f=null, speed: Float = 1,
            onFinish: () -> Void = null
        ) {
        var anim = new MoveToAnimation(object, position, speeds, speed);
        if (onFinish != null) { anim.onFinish = onFinish; }
        this.run(anim);
    }

    // mirrors MoveByAnimation constructor
    public function moveBy(
            object: h2d.Object, moveAmount: Point2f, speeds: Point2f=null, speed: Float = 1,
            onFinish: () -> Void = null
        ) {
        var anim = new MoveByAnimation(object, moveAmount, speeds, speed);
        if (onFinish != null) { anim.onFinish = onFinish; }
        this.run(anim);
    }
}

