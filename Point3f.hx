
package common;

abstract Point3f(Array<Float>) from Array<Float> to Array<Float> {
    public var x(get, set): Float;
    public var y(get, set): Float;
    public var z(get, set): Float;
    public function new(x: Float = 0, y: Float = 0, z: Float = 0) {
        this = [x, y, z];
    }

    public function toString(): String {
        return '{$x,$y,$z}';
    }

    @:op(A += B)
    public function add(rhs: Array<Float>): Point3f {
        this[0] += rhs[0];
        this[1] += rhs[1];
        this[2] += rhs[2];
        return this;
    }

    @:op(A + B)
    public function _add(rhs: Array<Float>): Point3f {
        return new Point3f(this[0]+rhs[0], this[1]+rhs[1], this[2]+rhs[2]);
    }

    @:op(A -= B)
    public function sub(rhs: Array<Float>): Point3f {
        this[0] -= rhs[0];
        this[1] -= rhs[1];
        this[2] -= rhs[2];
        return this;
    }

    @:op(A - B)
    public function _sub(rhs: Array<Float>): Point3f {
        return new Point3f(this[0]-rhs[0], this[1]-rhs[1], this[2]-rhs[2]);
    }

    @:op(A *= B)
    public function scale(rhs: Float): Point3f {
        this[0] *= rhs;
        this[1] *= rhs;
        this[2] *= rhs;
        return this;
    }

    @:op(A * B)
    public function _scale(rhs: Float): Point3f {
        return new Point3f(this[0]*rhs, this[1]*rhs, this[2]*rhs);
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
    public function toPoint2f(): Point2f {
        return new Point2f(this[0], this[1]);
    }

}
