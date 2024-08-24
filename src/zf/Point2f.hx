package zf;

/**
	@stage:stable
**/
abstract Point2f(Array<Float>) from Array<Float> to Array<Float> {
	public var x(get, set): Float;
	public var y(get, set): Float;
	public var unit(get, never): Point2f;
	public var abs(get, never): Point2f;
	public var rad(get, set): Float;
	public var mag(get, set): Float;

	inline public function new(x: Float = 0, y: Float = 0) {
		this = [x, y];
	}

	/**
		proxy this as min / max
	**/
	public var min(get, set): Float;

	inline public function get_min(): Float {
		return this[0];
	}

	inline public function set_min(v: Float): Float {
		return this[0] = v;
	}

	public var max(get, set): Float;

	inline public function get_max(): Float {
		return this[1];
	}

	inline public function set_max(v: Float): Float {
		return this[1] = v;
	}

	/**
		Difference between the 2 value, useful when we using this as min / max
	**/
	public var diff(get, never): Float;

	inline public function get_diff(): Float {
		return this[1] - this[0];
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

	public function xy(x: Float, y: Float): Point2f {
		this[0] = x;
		this[1] = y;
		return this;
	}

	inline public function clone(): Point2f {
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
		return distanceXY(point.x, point.y);
	}

	public function distanceXY(x: Float, y: Float): Float {
		return hxd.Math.sqrt(hxd.Math.pow(this[0] - x, 2) + hxd.Math.pow(this[1] - y, 2));
	}

	public function get_unit(): Point2f {
		// return a copy of the unit vector for this point
		final pt: Point2f = this.copy();
		return pt.normalize();
	}

	/**
		normalize the vector and return itself
	**/
	public function normalize(): Point2f {
		final mag = hxd.Math.sqrt(hxd.Math.pow(this[0], 2) + hxd.Math.pow(this[1], 2));
		this[0] *= (1 / mag);
		this[1] *= (1 / mag);
		return this;
	}

	public function get_abs(): Point2f {
		return [hxd.Math.abs(this[0]), hxd.Math.abs(this[1])];
	}

	public function get_rad(): Float {
		return hxd.Math.atan2(this[1], this[0]);
	}

	public function set_rad(r: Float): Float {
		final mag = hxd.Math.sqrt(hxd.Math.pow(this[0], 2) + hxd.Math.pow(this[1], 2));
		this[0] = Math.cos(r) * mag;
		this[1] = Math.sin(r) * mag;
		return r;
	}

	inline public function get_mag(): Float {
		return hxd.Math.sqrt(hxd.Math.pow(this[0], 2) + hxd.Math.pow(this[1], 2));
	}

	inline public function set_mag(m: Float): Float {
		// get the current mag
		final c = hxd.Math.sqrt(hxd.Math.pow(this[0], 2) + hxd.Math.pow(this[1], 2));
		this[0] *= (1 / c * m);
		this[1] *= (1 / c * m);
		return m;
	}

	/**
		Clamp the sum of vector

		start will be modified with the outcome.

		this will return [start.x + move.x, start.y + move.y].
		if the movement exceed the bound, then the value will be bounded by bound

		Assumption
		if start / move / bound is not a straight line, the outcome might look weird.
		if start + move is moving away from bound, it will immediately be set to bound.
	**/
	public static function clamp(start: Point2f, move: Point2f, bound: Point2f): Point2f {
		// handle each axis independently
		// handle x
		var valueX = start.x + move.x;
		if (move.x >= 0) {
			if (valueX >= bound.x) valueX = bound.x;
		} else {
			if (valueX <= bound.x) valueX = bound.x;
		}
		start.x = valueX;

		// handle y
		var valueY = start.y + move.y;
		if (move.y >= 0) {
			if (valueY >= bound.y) valueY = bound.y;
		} else {
			if (valueY <= bound.y) valueY = bound.y;
		}
		start.y = valueY;

		return start;
	}
}
