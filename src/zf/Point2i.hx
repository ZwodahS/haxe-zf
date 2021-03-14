package zf;

abstract Point2i(Array<Int>) from Array<Int> to Array<Int> {
	/**
		x component of the point
	**/
	public var x(get, set): Int;

	inline public function get_x(): Int {
		return this[0];
	}

	inline public function set_x(v: Int): Int {
		return this[0] = v;
	}

	/**
		y component of the point
	**/
	public var y(get, set): Int;

	inline public function get_y(): Int {
		return this[1];
	}

	inline public function set_y(v: Int): Int {
		return this[1] = v;
	}

	public function new(x: Int = 0, y: Int = 0) {
		this = [x, y];
	}

	/**
		return a string representation of the Point2i
	**/
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

	@:op(A != B)
	public function _notequal(rhs: Point2i): Bool {
		return !(this[0] == rhs.x && this[1] == rhs.y);
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

	/**
		Make a copy of this point
	**/
	inline public function copy(): Point2i {
		return [this[0], this[1]];
	}

	/**
		Make a copy of this point
	**/
	inline public function clone(): Point2i {
		return [this[0], this[1]];
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

	/**
		return a "distance" to another point
		Diagonal points have a distance of 2.
	**/
	public function distance(p: Point2i): Int {
		return hxd.Math.iabs(this[0] - p.x) + hxd.Math.iabs(this[1] - p.y);
	}

	/**
		Check if a point is around this point
	**/
	public function isAround(p: Point2i): Bool {
		// isAround check for if the point is a point around this point.
		if (p.x == this[0] && p.y == this[0]) return false;
		var xDiff = hxd.Math.iabs(this[0] - p.x);
		var yDiff = hxd.Math.iabs(this[1] - p.y);
		return xDiff <= 1 && yDiff <= 1;
	}

	/**
		Check if a point is adjacent to this point
	**/
	public function isAdjacent(p: Point2i): Bool {
		// isAdjacent check for if the point is directly adjacent to this, excluding diagonal
		var xDiff = hxd.Math.iabs(this[0] - p.x);
		var yDiff = hxd.Math.iabs(this[1] - p.y);
		return xDiff + yDiff == 1;
	}

	/**
		Get adjacent points
		.X.
		XOX
		.X.
	**/
	public function getAdjacent(): Array<Point2i> {
		var pts: Array<Point2i> = [];
		pts.push(new Point2i(this[0], this[1] - 1));
		pts.push(new Point2i(this[0], this[1] + 1));
		pts.push(new Point2i(this[0] - 1, this[1]));
		pts.push(new Point2i(this[0] + 1, this[1]));
		return pts;
	}

	/**
		Get diagonal points
		X.X
		.O.
		X.X
	**/
	public function getDiagonal(): Array<Point2i> {
		var pts: Array<Point2i> = [];
		pts.push(new Point2i(this[0] - 1, this[1] - 1));
		pts.push(new Point2i(this[0] + 1, this[1] - 1));
		pts.push(new Point2i(this[0] - 1, this[1] + 1));
		pts.push(new Point2i(this[0] + 1, this[1] + 1));
		return pts;
	}

	/**
		Get all points around this point.
		XXX
		XOX
		XXX
	**/
	public function getAround(): Array<Point2i> {
		var pts: Array<Point2i> = [];
		pts.push(new Point2i(this[0] - 1, this[1] - 1));
		pts.push(new Point2i(this[0], this[1] - 1));
		pts.push(new Point2i(this[0] + 1, this[1] - 1));
		pts.push(new Point2i(this[0] - 1, this[1]));
		pts.push(new Point2i(this[0] + 1, this[1]));
		pts.push(new Point2i(this[0] - 1, this[1] + 1));
		pts.push(new Point2i(this[0], this[1] + 1));
		pts.push(new Point2i(this[0] + 1, this[1] + 1));
		return pts;
	}

	/**
		Bound a point and treat this point as size.

		Essentially this will return a point that is within [0, 0, this.x-1, this.y-1];

		If pt value is < 0, it will be set to 0.
		If pt value is > this.value, it will be set to this.value - 1.

		if update is true, then the original pt will be updated.
		if update is false(default), then a copy of the pt will be updated.
	**/
	public function boundPoint(pt: Point2i, update: Bool = false): Point2i {
		var newPt = update ? pt : pt.clone();

		if (newPt.x < 0) {
			newPt.x = 0;
		} else if (newPt.x > this[0]) {
			newPt.x = this[0] - 1;
		}

		if (newPt.y < 0) {
			newPt.y = 0;
		} else if (newPt.y > this[1]) {
			newPt.y = this[1] - 1;
		}

		return newPt;
	}
}
