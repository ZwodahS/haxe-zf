
package common;

abstract Recti(Array<Int>) from Array<Int> to Array<Int> {

    public var xMin(get, set): Int;
    public var xMax(get, set): Int;
    public var yMin(get, set): Int;
    public var yMax(get, set): Int;

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

    public function intersect(rect: Recti): Bool {
        if (this[0] > rect.xMax || rect.xMin > this[2]) { return false; }
        if (this[1] > rect.yMax || rect.yMin > this[3]) { return false; }
        return true;
    }
}
