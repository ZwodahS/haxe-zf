package zf;

/**
	@stage:stable
**/
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

	inline public function new(x: Int = 0, y: Int = 0) {
		this = [x, y];
	}

	/**
		proxy this as min / max
	**/
	public var min(get, set): Int;

	inline public function get_min(): Int {
		return this[0];
	}

	inline public function set_min(v: Int): Int {
		return this[0] = v;
	}

	public var max(get, set): Int;

	inline public function get_max(): Int {
		return this[1];
	}

	inline public function set_max(v: Int): Int {
		return this[1] = v;
	}

	public var diff(get, never): Int;

	inline public function get_diff(): Int {
		return this[1] - this[0];
	}

	/**
		return a string representation of the Point2i
	**/
	public function toString(): String {
		return '{$x,$y}';
	}

	@:op(A += B)
	public function add(rhs: Point2i): Point2i {
		this[0] += rhs[0];
		this[1] += rhs[1];
		return this;
	}

	@:op(A + B)
	public function _add(rhs: Point2i): Point2i {
		return new Point2i(this[0] + rhs[0], this[1] + rhs[1]);
	}

	@:op(A -= B)
	public function sub(rhs: Point2i): Point2i {
		this[0] -= rhs[0];
		this[1] -= rhs[1];
		return this;
	}

	@:op(A - B)
	public function _sub(rhs: Point2i): Point2i {
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

	public function updateXY(x: Int, y: Int): Point2i {
		this[0] = x;
		this[1] = y;
		return this;
	}

	/**
		Move the point in this direction.
		Returns itself
	**/
	public function move(direction: Direction): Point2i {
		this[0] += direction.x;
		this[1] += direction.y;
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
		return the max diff between the 2 point in both axis
		this is the alternative to distance, where diagonal will be a distance of 1
	**/
	public function maxDiff(p: Point2i): Int {
		return hxd.Math.imax(hxd.Math.iabs(this[0] - p.x), hxd.Math.iabs(this[1] - p.y));
	}

	/**
		Check if a point is around this point
	**/
	public function isAround(p: Point2i): Bool {
		// isAround check for if the point is a point around this point.
		if (p.x == this[0] && p.y == this[1]) return false;
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
		Get an area around this point.

		range <= 0 (empty list)
		range == 1 (only this key)
		range == 2 (adjacent)
		range == 3 (around)
		range == 4

		..X..
		.XXX.
		XXOXX
		.XXX.
		..X..

		range == 5

		XXXXX
		XXXXX
		XXOXX
		XXXXX
		XXXXX

		currently only support up to 5. Implement whenever necessary
	**/
	public function getArea(range: Int): Array<Point2i> {
		if (range == 0) return [];
		if (range == 1) return [this.copy()];
		if (range == 2) {
			var pts = getAdjacent();
			pts.push(this.copy());
			return pts;
		}
		if (range == 3) {
			var pts = getAround();
			pts.push(this.copy());
			return pts;
		}
		if (range == 4) {
			var pts: Array<Point2i> = getAround();
			pts.push([this[0], this[1] - 2]);
			pts.push([this[0], this[1] + 2]);
			pts.push([this[0] - 2, this[1]]);
			pts.push([this[0] + 2, this[1]]);
			return pts;
		} else {
			var pts: Array<Point2i> = [];
			for (y in -2...3) {
				for (x in -2...3) {
					pts.push([this[0] + x, this[1] + y]);
				}
			}
			return pts;
		}
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
		} else if (newPt.x >= this[0]) {
			newPt.x = this[0] - 1;
		}

		if (newPt.y < 0) {
			newPt.y = 0;
		} else if (newPt.y >= this[1]) {
			newPt.y = this[1] - 1;
		}

		return newPt;
	}

	/**
		Return a point2i representing row and column based on index

		Example, if columnPerRow is 4, then index will return

		[0] [1] [2] [3]
		[4] [5] [6] [7]

		so 6 will return [2, 1]

		@param columnPerRow number of item in each row
		@param index the index in the grid
	**/
	inline public static function rowColumn(columnPerRow: Int, index: Int, pt: Point2i = null): Point2i {
		if (pt == null) pt = [0, 0];
		pt.x = Std.int(index % columnPerRow);
		pt.y = Std.int(index / columnPerRow);
		return pt;
	}

	/**
		Return a point2i representing row and column based on index

		Example, if rowPerColumn is 4, then index will return

		[0] [4]
		[1] [5]
		[2] [6]
		[3] [7]

		so 6 will return [1, 2]

		@param rowPerColumn number of item in each column
		@param index the index in the grid
	**/
	inline public static function columnRow(rowPerColumn: Int, index: Int, pt: Point2i = null): Point2i {
		if (pt == null) pt = [0, 0];
		pt.x = Std.int(index / rowPerColumn);
		pt.y = Std.int(index % rowPerColumn);
		return pt;
	}
}
