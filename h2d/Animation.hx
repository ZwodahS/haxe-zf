package common.h2d;

import common.Updater;
import common.Point2f;
import common.MathUtils;
import common.animations.Positionable;
import common.animations.Scalable;
import common.animations.Alphable;
import common.animations.Rotatable;

class MoveToLocationByDurationAnimation extends common.animations.MoveToLocationByDuration
        implements Positionable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, position: Point2f, duration: Float) {
        this.h2dObject = h2dObject;
        super(this, position, duration);
    }

    public var x(get, set): Float;

    public function get_x(): Float {
        return this.h2dObject.x;
    }

    public function set_x(x: Float): Float {
        return this.h2dObject.x = x;
    }

    public var y(get, set): Float;

    public function get_y(): Float {
        return this.h2dObject.y;
    }

    public function set_y(y: Float): Float {
        return this.h2dObject.y = y;
    }
}

class MoveToLocationBySpeedAnimation extends common.animations.MoveToLocationBySpeed implements Positionable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, position: Point2f, speeds: Point2f = null, speed: Float = 1) {
        this.h2dObject = h2dObject;
        super(this, position, speeds, speed);
    }

    public var x(get, set): Float;

    public function get_x(): Float {
        return this.h2dObject.x;
    }

    public function set_x(x: Float): Float {
        return this.h2dObject.x = x;
    }

    public var y(get, set): Float;

    public function get_y(): Float {
        return this.h2dObject.y;
    }

    public function set_y(y: Float): Float {
        return this.h2dObject.y = y;
    }
}

class MoveByAmountBySpeedAnimation extends common.animations.MoveByAmountBySpeed implements Positionable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, moveAmount: Point2f, speeds: Point2f = null,
            speed: Float = 1) {
        this.h2dObject = h2dObject;
        super(this, moveAmount, speeds, speed);
    }

    public var x(get, set): Float;

    public function get_x(): Float {
        return this.h2dObject.x;
    }

    public function set_x(x: Float): Float {
        return this.h2dObject.x = x;
    }

    public var y(get, set): Float;

    public function get_y(): Float {
        return this.h2dObject.y;
    }

    public function set_y(y: Float): Float {
        return this.h2dObject.y = y;
    }
}

class MoveByAmountByDuration extends common.animations.MoveByAmountByDuration implements Positionable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, amount: Point2f, duration: Float) {
        this.h2dObject = h2dObject;
        super(this, amount, duration);
    }

    public var x(get, set): Float;

    public function get_x(): Float {
        return this.h2dObject.x;
    }

    public function set_x(x: Float): Float {
        return this.h2dObject.x = x;
    }

    public var y(get, set): Float;

    public function get_y(): Float {
        return this.h2dObject.y;
    }

    public function set_y(y: Float): Float {
        return this.h2dObject.y = y;
    }
}

class MoveBySpeedByDuration extends common.animations.MoveBySpeedByDuration implements Positionable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, moveDuration: Float, moveSpeeds: Point2f = null,
            moveSpeed: Float = 1) {
        this.h2dObject = h2dObject;
        super(this, moveDuration, moveSpeeds, moveSpeed);
    }

    public var x(get, set): Float;

    public function get_x(): Float {
        return this.h2dObject.x;
    }

    public function set_x(x: Float): Float {
        return this.h2dObject.x = x;
    }

    public var y(get, set): Float;

    public function get_y(): Float {
        return this.h2dObject.y;
    }

    public function set_y(y: Float): Float {
        return this.h2dObject.y = y;
    }
}

class ScaleToAnimation extends common.animations.ScaleTo implements Scalable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, scaleTo: Point2f, speeds: Point2f = null, speed: Float = 1) {
        this.h2dObject = h2dObject;
        super(this, scaleTo, speeds, speed);
    }

    public var scaleX(get, set): Float;

    public function set_scaleX(scaleX: Float): Float {
        return this.h2dObject.scaleX = scaleX;
    }

    public function get_scaleX(): Float {
        return this.h2dObject.scaleX;
    }

    public var scaleY(get, set): Float;

    public function set_scaleY(scaleY: Float): Float {
        return this.h2dObject.scaleY = scaleY;
    }

    public function get_scaleY(): Float {
        return this.h2dObject.scaleY;
    }
}

class AlphaToAnimation extends common.animations.AlphaTo implements Alphable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, alphaTo: Float, alphaSpeed: Float = 1.0) {
        this.h2dObject = h2dObject;
        super(this, alphaTo, alphaSpeed);
    }

    public var alpha(get, set): Float;

    public function set_alpha(alpha: Float): Float {
        return this.h2dObject.alpha = alpha;
    }

    public function get_alpha(): Float {
        return this.h2dObject.alpha;
    }
}

class RotateAnimation extends common.animations.Rotate implements Rotatable {
    var h2dObject: h2d.Object;

    public function new(h2dObject: h2d.Object, rotateSpeed: Float, duration: Null<Float> = null) {
        this.h2dObject = h2dObject;
        super(this, rotateSpeed, duration);
    }

    public var rotation(get, set): Float;

    public function set_rotation(rotation: Float): Float {
        return this.h2dObject.rotation = rotation;
    }

    public function get_rotation(): Float {
        return this.h2dObject.rotation;
    }
}
