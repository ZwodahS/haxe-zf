package common.h2d;

import common.animations.Alphable;
import common.animations.Scalable;
import common.animations.Positionable;

class WrappedBatchElement implements Alphable implements Scalable implements Positionable {
    public var element: h2d.SpriteBatch.BatchElement;

    public function new(e: h2d.SpriteBatch.BatchElement) {
        this.element = e;
    }

    public var alpha(get, set): Float;

    inline public function set_alpha(a: Float): Float {
        return element.a = a;
    }

    inline public function get_alpha(): Float {
        return element.a;
    }

    public var scaleX(get, set): Float;

    inline public function set_scaleX(x: Float): Float {
        return this.element.scaleX = x;
    }

    inline public function get_scaleX(): Float {
        return this.element.scaleX;
    }

    public var scaleY(get, set): Float;

    inline public function set_scaleY(y: Float): Float {
        return this.element.scaleY = y;
    }

    inline public function get_scaleY(): Float {
        return this.element.scaleY;
    }

    public var x(get, set): Float;

    inline public function set_x(x: Float): Float {
        return this.element.x = x;
    }

    inline public function get_x(): Float {
        return this.element.x;
    }

    public var y(get, set): Float;

    inline public function set_y(y: Float): Float {
        return this.element.y = y;
    }

    inline public function get_y(): Float {
        return this.element.y;
    }
}
