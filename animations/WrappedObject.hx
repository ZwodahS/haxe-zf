package common.animations;

import common.animations.Alphable;
import common.animations.Scalable;
import common.animations.Positionable;

class WrappedObject implements Alphable implements Scalable implements Positionable {
    public var object: h2d.Object;

    public function new(o: h2d.Object) {
        this.object = o;
    }

    public var alpha(get, set): Float;

    inline public function set_alpha(a: Float): Float {
        return object.alpha = a;
    }

    inline public function get_alpha(): Float {
        return object.alpha;
    }

    public var scaleX(get, set): Float;

    inline public function set_scaleX(x: Float): Float {
        return this.object.scaleX = x;
    }

    inline public function get_scaleX(): Float {
        return this.object.scaleX;
    }

    public var scaleY(get, set): Float;

    inline public function set_scaleY(y: Float): Float {
        return this.object.scaleY = y;
    }

    inline public function get_scaleY(): Float {
        return this.object.scaleY;
    }

    public var x(get, set): Float;

    inline public function set_x(x: Float): Float {
        return this.object.x = x;
    }

    inline public function get_x(): Float {
        return this.object.x;
    }

    public var y(get, set): Float;

    inline public function set_y(y: Float): Float {
        return this.object.y = y;
    }

    inline public function get_y(): Float {
        return this.object.y;
    }
}
