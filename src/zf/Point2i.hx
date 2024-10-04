package zf;

import zf.serialise.Serialisable;

@:forward abstract ArrPoint2i(Array<Point2iImpl>) from Array<Point2iImpl> to Array<Point2iImpl> {
	public function dispose() {
		for (pt in this) {
			pt.dispose();
		}
	}
}

#if !macro @:build(zf.macros.ObjectPool.build()) #end
#if !macro @:build(zf.macros.Serialise.build()) #end
class Point2iImpl implements Serialisable implements Disposable {
	@:serialise @:dispose public var x: Int = 0;
	@:serialise @:dispose public var y: Int = 0;

	function new() {}

	public function setX(x: Int): Point2iImpl {
		this.x = x;
		return this;
	}

	public function setY(y: Int): Point2iImpl {
		this.y = y;
		return this;
	}

	public function set(x: Int, y: Int): Point2iImpl {
		this.x = x;
		this.y = y;
		return this;
	}

	public function setPoint(pt: Point2i): Point2iImpl {
		this.x = pt.x;
		this.y = pt.y;
		return this;
	}

	/**
		Move the point in this direction.
		Returns itself
	**/
	public function move(direction: Direction): Point2iImpl {
		this.x += direction.x;
		this.y += direction.y;
		return this;
	}

	/**
		return a string representation of the Point2i
	**/
	public function toString(): String {
		return '{$x,$y}';
	}

	/**
		Make a clone of this point
	**/
	inline public function clone(): Point2iImpl {
		return Point2iImpl.alloc(this.x, this.y);
	}

	public static function alloc(x: Int, y: Int): Point2iImpl {
		final pt = Point2iImpl.__alloc__();
		pt.x = x;
		pt.y = y;
		return pt;
	}

	/**
		return a "distance" to another point
		Diagonal points have a distance of 2.
	**/
	public function distance(p: Point2i): Int {
		return hxd.Math.iabs(this.x - p.x) + hxd.Math.iabs(this.y - p.y);
	}

	/**
		return the max diff between the 2 point in both axis
		this is the alternative to distance, where diagonal will be a distance of 1
	**/
	public function maxDiff(p: Point2i): Int {
		return hxd.Math.imax(hxd.Math.iabs(this.x - p.x), hxd.Math.iabs(this.y - p.y));
	}

	/**
		Check if a point is around this point
	**/
	public function isAround(p: Point2i): Bool {
		// isAround check for if the point is a point around this point.
		if (p.x == this.x && p.y == this.y) return false;
		var xDiff = hxd.Math.iabs(this.x - p.x);
		var yDiff = hxd.Math.iabs(this.y - p.y);
		return xDiff <= 1 && yDiff <= 1;
	}

	/**
		Check if a point is adjacent to this point
	**/
	public function isAdjacent(p: Point2i): Bool {
		// isAdjacent check for if the point is directly adjacent to this, excluding diagonal
		var xDiff = hxd.Math.iabs(this.x - p.x);
		var yDiff = hxd.Math.iabs(this.y - p.y);
		return xDiff + yDiff == 1;
	}

	/**
		Get adjacent points
		.X.
		XOX
		.X.
	**/
	public function getAdjacent(): ArrPoint2i {
		var pts: Array<Point2i> = [];
		pts.push(Point2iImpl.alloc(this.x, this.y - 1));
		pts.push(Point2iImpl.alloc(this.x, this.y + 1));
		pts.push(Point2iImpl.alloc(this.x - 1, this.y));
		pts.push(Point2iImpl.alloc(this.x + 1, this.y));
		return pts;
	}

	/**
		Get diagonal points
		X.X
		.O.
		X.X
	**/
	public function getDiagonal(): ArrPoint2i {
		var pts: Array<Point2i> = [];
		pts.push(Point2iImpl.alloc(this.x - 1, this.y - 1));
		pts.push(Point2iImpl.alloc(this.x + 1, this.y - 1));
		pts.push(Point2iImpl.alloc(this.x - 1, this.y + 1));
		pts.push(Point2iImpl.alloc(this.x + 1, this.y + 1));
		return pts;
	}

	/**
		Get all points around this point.
		XXX
		XOX
		XXX
	**/
	public function getAround(): ArrPoint2i {
		var pts: Array<Point2i> = [];
		pts.push(Point2iImpl.alloc(this.x - 1, this.y - 1));
		pts.push(Point2iImpl.alloc(this.x, this.y - 1));
		pts.push(Point2iImpl.alloc(this.x + 1, this.y - 1));
		pts.push(Point2iImpl.alloc(this.x - 1, this.y));
		pts.push(Point2iImpl.alloc(this.x + 1, this.y));
		pts.push(Point2iImpl.alloc(this.x - 1, this.y + 1));
		pts.push(Point2iImpl.alloc(this.x, this.y + 1));
		pts.push(Point2iImpl.alloc(this.x + 1, this.y + 1));
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
	public function getArea(range: Int): ArrPoint2i {
		if (range == 0) return [];
		if (range == 1) return [this.clone()];
		if (range == 2) {
			var pts = getAdjacent();
			pts.push(this.clone());
			return pts;
		}
		if (range == 3) {
			var pts = getAround();
			pts.push(this.clone());
			return pts;
		}
		if (range == 4) {
			var pts: Array<Point2i> = getAround();
			pts.push([this.x, this.y - 2]);
			pts.push([this.x, this.y + 2]);
			pts.push([this.x - 2, this.y]);
			pts.push([this.x + 2, this.y]);
			return pts;
		} else {
			var pts: Array<Point2i> = [];
			for (y in -2...3) {
				for (x in -2...3) {
					pts.push([this.x + x, this.y + y]);
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
		if update is false(default), then a clone of the pt will be updated.
	**/
	public function boundPoint(pt: Point2i, update: Bool = false): Point2i {
		var newPt = update ? pt : pt.clone();

		if (newPt.x < 0) {
			newPt.x = 0;
		} else if (newPt.x >= this.x) {
			newPt.x = this.x - 1;
		}

		if (newPt.y < 0) {
			newPt.y = 0;
		} else if (newPt.y >= this.y) {
			newPt.y = this.y - 1;
		}

		return newPt;
	}
}

@:forward abstract Point2i(Point2iImpl) from Point2iImpl to Point2iImpl {
	public function new(x: Int = 0, y: Int = 0) {
		this = Point2iImpl.alloc(x, y);
	}

	/**
		proxy this as min / max
	**/
	public var min(get, set): Int;

	inline public function get_min(): Int {
		return this.x;
	}

	inline public function set_min(v: Int): Int {
		return this.x = v;
	}

	public var max(get, set): Int;

	inline public function get_max(): Int {
		return this.y;
	}

	inline public function set_max(v: Int): Int {
		return this.y = v;
	}

	public var diff(get, never): Int;

	inline public function get_diff(): Int {
		return this.y - this.x;
	}

	@:op(A == B)
	public function _equal(rhs: Point2i): Bool {
		return this.x == rhs.x && this.y == rhs.y;
	}

	@:op(A != B)
	public function _notequal(rhs: Point2i): Bool {
		return !(this.x == rhs.x && this.y == rhs.y);
	}

	@:to
	public function toPoint2f(): Point2f {
		return new Point2f(this.x, this.y);
	}

	@:to
	public function toPoint3i(): Point3i {
		return new Point3i(this.x, this.y, 0);
	}

	@:to
	public function toPoint3f(): Point3f {
		return new Point3f(this.x, this.y, 0);
	}

	@:from
	public static function fromArrayInt(arr: Array<Int>): Point2i {
		return Point2iImpl.alloc(arr.length > 0 ? arr[0] : 0, arr.length > 1 ? arr[1] : 0);
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

	public static function alloc(x: Int = 0, y: Int = 0): Point2i {
		return Point2iImpl.alloc(x, y);
	}
}
/**
	Fri 12:44:15 20 Sep 2024
	Convert this from abstract(Array<Int>) to object pooled object.
	Removed methods that are seldom used and don't make sense for an object pool version of Point2i

	Fri 13:41:03 04 Oct 2024
	Another possible improvement is to wrap h2d.col.IPoint in Point2i, and just forward the fields.
	This way, in places where we need IPoint, we could just return the inner pt and the x/y can be modified
	and we don't have to update Point2i.

	This will also apply to Point2f, Point3i, Point3f.

**/
