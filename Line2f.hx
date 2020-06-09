package common;

class Line2f {
    public var start(get, set): Point2f;
    public var end(get, set): Point2f;

    var _start: Point2f;
    var _end: Point2f;
    var _unit: Point2f;
    var _mag: Float;
    var _rad: Float;

    public var unitVector(get, null): Point2f;
    public var mag(get, set): Float;
    public var rad(get, null): Float;

    public function new(start, end) {
        this.setStartEnd(start, end);
    }

    public function toString(): String {
        return '[${start}] -> [${end}]';
    }

    public function set_start(s: Point2f): Point2f {
        setStartEnd(s, this.end);
        return this._start;
    }

    public function get_start(): Point2f {
        return this._start;
    }

    public function set_end(e: Point2f): Point2f {
        setStartEnd(this.start, e);
        return this._end;
    }

    public function get_end(): Point2f {
        return this._end;
    }

    function setStartEnd(s: Point2f, e: Point2f) {
        this._start = s;
        this._end = e;
        this._mag = hxd.Math.sqrt(hxd.Math.pow(hxd.Math.abs(this._start.x - this._end.x), 2)
            + hxd.Math.pow(hxd.Math.abs(this._start.y - this._end.y), 2));
        this._unit = (this._end - this._start) * (1 / this._mag);
        this._rad = hxd.Math.atan2(this._unit.y, this._unit.x);
    }

    public function get_unitVector(): Point2f {
        return this._unit;
    }

    public function get_mag(): Float {
        return this._mag;
    }

    public function set_mag(m: Float): Float {
        this._mag = m;
        this._end = this._start + this._unit * this._mag;
        return this._mag;
    }

    public function intersect(line: Line2f): Point2f {
        // https://ncase.me/sight-and-light/
        if (this.unitVector == line.unitVector) return null;
        // solve for intersection
        var p0 = this.start;
        var m0 = this.mag;
        var u0 = this.unitVector;

        var p1 = line.start;
        var m1 = line.mag;
        var u1 = line.unitVector;

        // See link above for math
        // get the collision mag respect to target line
        var c1 = ((u0.x * (p1.y - p0.y)) + (u0.y * (p0.x - p1.x))) / ((u1.x * u0.y) - (u0.x * u1.y));
        var c0: Float = 0;
        if (u0.x == 0) { // use y because are going in a specific direction
            c0 = (p1.y + (c1 * u1.y) - p0.y) / u0.y;
        } else {
            c0 = (p1.x + (c1 * u1.x) - p0.x) / u0.x;
        }
        if (c0 > 0 && c0 < this.mag && c1 > 0 && c1 < line.mag) return this.start + (this.unitVector * c0);
        return null;
    }

    public function copy(): Line2f {
        return new Line2f(this._start, this._end);
    }

    public function get_rad(): Float {
        return this._rad;
    }

    public function rotate(r: Float) {
        var rad = this._rad;
        rad += r;
        var newUnit: Point2f = [hxd.Math.cos(rad), hxd.Math.sin(rad)];
        this.setStartEnd(this._start, this._start + newUnit.unit * this._mag);
    }
}
