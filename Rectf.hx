
package common;

abstract Rectf(Array<Float>) from Array<Float> to Array<Float> {

    public var xMin(get, set): Float;
    public var xMax(get, set): Float;
    public var yMin(get, set): Float;
    public var yMax(get, set): Float;

    public function new(xMin: Float = 0, yMin: Float = 0, xMax: Float = 0, yMax: Float = 0) {
        this = [xMin, yMin, xMax, yMax];
    }

    public function set_xMin(xMin: Float): Float {
        this[0] = xMin;
        return this[0];
    }
    public function get_xMin(): Float {
        return this[0];
    }

    public function set_xMax(xMax: Float): Float {
        this[2] = xMax;
        return this[2];
    }
    public function get_xMax(): Float {
        return this[2];
    }

    public function set_yMin(yMin: Float): Float {
        this[1] = yMin;
        return this[1];
    }
    public function get_yMin(): Float {
        return this[1];
    }

    public function set_yMax(yMax: Float): Float {
        this[3] = yMax;
        return this[3];
    }
    public function get_yMax(): Float {
        return this[3];
    }

    public function intersect(rect: Rectf): Bool {
        if (this[0] >= rect.xMax || rect.xMin >= this[2]) { return false; }
        if (this[1] >= rect.yMax || rect.yMin >= this[3]) { return false; }
        return true;
    }

    public function intersectWithBorder(rect: Rectf): Bool {
        if (this[0] > rect.xMax || rect.xMin > this[2]) { return false; }
        if (this[1] > rect.yMax || rect.yMin > this[3]) { return false; }
        return true;
    }

    public function contains(point: Point2f): Bool {
        return (
            this[0] <= point.x && this[2] >= point.x &&
            this[1] <= point.y && this[3] >= point.y);
    }
}
