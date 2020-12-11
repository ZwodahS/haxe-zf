package zf;

abstract Point2i(Array<Int>) from Array<Int> to Array<Int> {
    public var x(get, set): Int;
    public var y(get, set): Int;

    public function new(x: Int = 0, y: Int = 0) {
        this = [x, y];
    }

    public function toString(): String {
        return '{$x,$y}';
    }

    @:op(A += B)
    public function add(rhs: Array<Int>): Point2i {
        this[0] += rhs[0];
        this[1] += rhs[1];
        return this;
    }

    @:op(A + B)
    public function _add(rhs: Array<Int>): Point2i {
        return new Point2i(this[0] + rhs[0], this[1] + rhs[1]);
    }

    @:op(A -= B)
    public function sub(rhs: Array<Int>): Point2i {
        this[0] -= rhs[0];
        this[1] -= rhs[1];
        return this;
    }

    @:op(A - B)
    public function _sub(rhs: Array<Int>): Point2i {
        return new Point2i(this[0] - rhs[0], this[1] - rhs[1]);
    }

    @:op(A == B)
    public function _equal(rhs: Point2i): Bool {
        return this[0] == rhs.x && this[1] == rhs.y;
    }

    @:op(A * B)
    public function _scale(rhs: Int): Point2i {
        return new Point2i(this[0] * rhs, this[1] * rhs);
    }

    public function update(rhs: Point2i): Point2i {
        this[0] = rhs[0];
        this[1] = rhs[1];
        return this;
    }

    inline public function copy(): Point2i {
        return [this[0], this[1]];
    }

    inline public function get_x(): Int {
        return this[0];
    }

    inline public function set_x(v: Int): Int {
        return this[0] = v;
    }

    inline public function get_y(): Int {
        return this[1];
    }

    inline public function set_y(v: Int): Int {
        return this[1] = v;
    }

    @:to
    public function toPoint2f(): Point2f {
        return new Point2f(this[0], this[1]);
    }

    @:to
    public function toPoint3i(): Point3i {
        return new Point3i(this[0], this[1], 0);
    }

    @:to
    public function toPoint3f(): Point3f {
        return new Point3f(this[0], this[1], 0);
    }

    public function distance(p: Point2i): Int {
        return hxd.Math.iabs(this[0] - p.x) + hxd.Math.iabs(this[1] - p.y);
    }

    public function isAround(p: Point2i): Bool {
        // isAround check for if the point is a point around this point.
        if (p.x == this[0] && p.y == this[0]) return false;
        var xDiff = hxd.Math.iabs(this[0] - p.x);
        var yDiff = hxd.Math.iabs(this[1] - p.y);
        return xDiff <= 1 && yDiff <= 1;
    }

    public function isAdjacent(p: Point2i): Bool {
        // isAdjacent check for if the point is directly adjacent to this, excluding diagonal
        var xDiff = hxd.Math.iabs(this[0] - p.x);
        var yDiff = hxd.Math.iabs(this[1] - p.y);
        return xDiff + yDiff == 1;
    }

    public function getAdjacent(): Array<Point2i> {
        var pts: Array<Point2i> = [];
        pts.push(new Point2i(this[0], this[1] - 1));
        pts.push(new Point2i(this[0], this[1] + 1));
        pts.push(new Point2i(this[0] - 1, this[1]));
        pts.push(new Point2i(this[0] + 1, this[1]));
        return pts;
    }
}
