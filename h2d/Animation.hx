
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

// need "anchor" while scaling, or this will always scale relative to top left
class ScaleToAnimation extends Animation {

    var object: h2d.Object;
    var scaleTo: Point2f;
    var scaleSpeed: Point2f;

    public function new(object: h2d.Object, scaleTo: Point2f, speeds: Point2f = null, speed: Float = 1) {
        super();
        this.object = object;
        this.scaleTo = scaleTo;
        this.scaleSpeed = speeds != null ? speeds : [ speed, speed ];
    }

    override public function isDone(): Bool { return this.scaleTo == [ this.object.scaleX, this.object.scaleY ]; }

    override public function update(dt: Float) {
        if (this.isDone()) { return; }

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

class AlphaToAnimation extends Animation {
    var object: h2d.Object;
    var alphaTo: Float;
    var alphaSpeed: Float;

    public function new(object: h2d.Object, alphaTo: Float, alphaSpeed: Float = 1.0) {
        super();
        this.object = object;
        this.alphaTo = alphaTo;
        this.alphaSpeed = alphaSpeed;
    }

    override public function isDone(): Bool { return this.object.alpha == this.alphaTo; }
    override public function update(dt: Float) {
        if (this.isDone()) { return; }

        var sign = this.object.alpha > this.alphaTo ? -1 : 1;
        var delta = this.alphaSpeed * dt * sign;
        if (delta < 0) {
            this.object.alpha = Math.max(this.object.alpha + delta, this.alphaTo);
        } else {
            this.object.alpha = Math.min(this.object.alpha + delta, this.alphaTo);
        }
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

    public function scaleTo(
            object: h2d.Object, scaleTo: Point2f, speeds: Point2f = null, speed: Float = 1,
            onFinish: () -> Void = null
        ) {
        var anim = new ScaleToAnimation(object, scaleTo, speeds, speed);
        if (onFinish != null) { anim.onFinish = onFinish; }
        this.run(anim);
    }

    public function alphaTo(
            object: h2d.Object, alphaTo: Float, alphaSpeed:Float = 1.0,
            onFinish: () -> Void = null
        ) {
        var anim = new AlphaToAnimation(object, alphaTo, alphaSpeed);
        if (onFinish != null) { anim.onFinish = onFinish; }
        this.run(anim);
    }
}

