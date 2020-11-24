package zf;

abstract Point2f(Array<Float>) from Array<Float> to Array<Float> {
    public var x(get, set): Float;
    public var y(get, set): Float;
    public var unit(get, never): Point2f;
    public var rad(get, never): Float;

    public function new(x: Float = 0, y: Float = 0) {
        this = [x, y];
    }

    public function toString(): String {
        return '{$x,$y}';
    }

    @:op(A += B)
    public function add(rhs: Array<Float>): Point2f {
        this[0] += rhs[0];
        this[1] += rhs[1];
        return this;
    }

    @:op(A + B)
    public function _add(rhs: Array<Float>): Point2f {
        return new Point2f(this[0] + rhs[0], this[1] + rhs[1]);
    }

    @:op(A -= B)
    public function sub(rhs: Array<Float>): Point2f {
        this[0] -= rhs[0];
        this[1] -= rhs[1];
        return this;
    }

    @:op(A - B)
    public function _sub(rhs: Array<Float>): Point2f {
        return new Point2f(this[0] - rhs[0], this[1] - rhs[1]);
    }

    @:op(A *= B)
    public function scale(rhs: Float): Point2f {
        this[0] *= rhs;
        this[1] *= rhs;
        return this;
    }

    @:op(A * B)
    public function _scale(rhs: Float): Point2f {
        return new Point2f(this[0] * rhs, this[1] * rhs);
    }

    @:op(A == B)
    public function _equal(rhs: Point2f): Bool {
        return this[0] == rhs.x && this[1] == rhs.y;
    }

    public function update(rhs: Point2f): Point2f {
        this[0] = rhs[0];
        this[1] = rhs[1];
        return this;
    }

    inline public function copy(): Point2f {
        return [this[0], this[1]];
    }

    inline public function get_x(): Float {
        return this[0];
    }

    inline public function set_x(v: Float): Float {
        return this[0] = v;
    }

    inline public function get_y(): Float {
        return this[1];
    }

    inline public function set_y(v: Float): Float {
        return this[1] = v;
    }

    inline public function get_z(): Float {
        return this[2];
    }

    inline public function set_z(v: Float): Float {
        return this[2] = v;
    }

    @:to
    public function toPoint3f(): Point3f {
        return new Point3f(this[0], this[1], 0);
    }

    @:to public function toh2dPoint(): h2d.col.Point {
        return new h2d.col.Point(this[0], this[1]);
    }

    @:from static public function fromh2dPoint(p: h2d.col.Point): Point2f {
        return new Point2f(p.x, p.y);
    }

    public function distance(point: Point2f): Float {
        return hxd.Math.sqrt(hxd.Math.pow(hxd.Math.abs(this[0] - point.x), 2)
            + hxd.Math.pow(hxd.Math.abs(this[1] - point.y), 2));
    }

    public function get_unit(): Point2f {
        // return a copy of the unit vector for this point
        var mag = hxd.Math.sqrt(hxd.Math.pow(this[0], 2) + hxd.Math.pow(this[1], 2));
        return [this[0] * (1 / mag), this[1] * (1 / mag)];
    }

    public function get_rad(): Float {
        return hxd.Math.atan2(this[1], this[0]);
    }
}
