package zf;

abstract Recti(Array<Int>) from Array<Int> to Array<Int> {
    public var xMin(get, set): Int;
    public var xMax(get, set): Int;
    public var yMin(get, set): Int;
    public var yMax(get, set): Int;
    public var left(get, set): Int;
    public var right(get, set): Int;
    public var top(get, set): Int;
    public var bottom(get, set): Int;

    public var xDiff(get, never): Int;
    public var yDiff(get, never): Int;
    public var area(get, never): Int;

    public function new(xMin: Int = 0, yMin: Int = 0, xMax: Int = 0, yMax: Int = 0) {
        this = [xMin, yMin, xMax, yMax];
    }

    public function set_xMin(xMin: Int): Int {
        this[0] = xMin;
        return this[0];
    }

    public function get_xMin(): Int {
        return this[0];
    }

    public function set_xMax(xMax: Int): Int {
        this[2] = xMax;
        return this[2];
    }

    public function get_xMax(): Int {
        return this[2];
    }

    public function set_yMin(yMin: Int): Int {
        this[1] = yMin;
        return this[1];
    }

    public function get_yMin(): Int {
        return this[1];
    }

    public function set_yMax(yMax: Int): Int {
        this[3] = yMax;
        return this[3];
    }

    public function get_yMax(): Int {
        return this[3];
    }

    public function set_left(left: Int): Int {
        this[0] = left;
        return this[0];
    }

    public function get_left(): Int {
        return this[0];
    }

    public function set_right(right: Int): Int {
        this[2] = right;
        return this[2];
    }

    public function get_right(): Int {
        return this[2];
    }

    public function set_top(top: Int): Int {
        this[1] = top;
        return this[1];
    }

    public function get_top(): Int {
        return this[1];
    }

    public function set_bottom(bottom: Int): Int {
        this[3] = bottom;
        return this[3];
    }

    public function get_bottom(): Int {
        return this[3];
    }

    public function intersect(rect: Recti): Bool {
        if (this[0] > rect.xMax || rect.xMin > this[2]) {
            return false;
        }
        if (this[1] > rect.yMax || rect.yMin > this[3]) {
            return false;
        }
        return true;
    }

    public function get_xDiff(): Int {
        return this[2] - this[0];
    }

    public function get_yDiff(): Int {
        return this[3] - this[1];
    }

    public function get_area(): Int {
        return (xDiff + 1) + (yDiff + 1);
    }

    public function clone(): Recti {
        return [this[0], this[1], this[2], this[3]];
    }

    public function copy(): Recti {
        return [this[0], this[1], this[2], this[3]];
    }
}
