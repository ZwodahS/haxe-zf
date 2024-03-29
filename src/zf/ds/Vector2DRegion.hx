package zf.ds;

/**
	@stage:stable

	This provide a wrapper around a Vector2D to handle sub region.
**/
class Vector2DRegionIterator<T> {
	var region: Vector2DRegion<T>;
	var currX: Int;
	var currY: Int;

	public function new(region: Vector2DRegion<T>) {
		this.region = region;
		this.currX = 0;
		this.currY = 0;
	}

	public function hasNext(): Bool {
		return (this.currX < this.region.size.x && this.currY < this.region.size.y);
	}

	public function next(): {key: Point2i, value: T} {
		var returnValue = {
			key: new Point2i(this.currX, this.currY),
			value: this.region.get(this.currX, this.currY),
		}
		@:privateAccess
		if (this.currX == this.region.size.x - 1) {
			this.currY += 1;
			this.currX = 0;
		} else {
			this.currX += 1;
		}
		return returnValue;
	}
}

class Vector2DRegionRowIterator<T> {
	var region: Vector2DRegion<T>;
	var currX: Int;
	var currY: Int;
	var reversed: Bool = false;

	public function new(region: Vector2DRegion<T>, startX: Int, startY: Int, reversed = false) {
		this.region = region;
		this.currX = startX;
		this.currY = startY;
		this.reversed = reversed;
	}

	public function hasNext(): Bool {
		return (this.currX >= 0
			&& this.currX < this.region.size.x
			&& this.currY >= 0
			&& this.currY < this.region.size.y);
	}

	public function next(): {key: Point2i, value: T} {
		var returnValue = {
			key: new Point2i(this.currX, this.currY),
			value: this.region.get(this.currX, this.currY),
		}
		if (reversed) {
			this.currX -= 1;
		} else {
			this.currX += 1;
		}
		return returnValue;
	}
}

class Vector2DRegionColumnIterator<T> {
	var region: Vector2DRegion<T>;
	var currX: Int;
	var currY: Int;
	var reversed: Bool = false;

	public function new(region: Vector2DRegion<T>, startX: Int, startY: Int, reversed = false) {
		this.region = region;
		this.currX = startX;
		this.currY = startY;
		this.reversed = reversed;
	}

	public function hasNext(): Bool {
		return (this.currX >= 0
			&& this.currX < this.region.size.x
			&& this.currY >= 0
			&& this.currY < this.region.size.y);
	}

	public function next(): {key: Point2i, value: T} {
		var returnValue = {
			key: new Point2i(this.currX, this.currY),
			value: this.region.get(this.currX, this.currY),
		}
		if (reversed) {
			this.currY -= 1;
		} else {
			this.currY += 1;
		}
		return returnValue;
	}
}

class Vector2DRegion<T> {
	public var grid: Vector2D<T>;

	var subRect: Recti = null;

	public var size(default, null): Point2i;

	public function new(grid: Vector2D<T>, subRect: Recti = null) {
		this.grid = grid;
		if (subRect == null) {
			subRect = new Recti(0, 0, grid.size.x - 1, grid.size.y - 1);
		}
		this.subRect = subRect;
		ensureBound();
		this.size = [this.subRect.width, this.subRect.height];
	}

	function ensureBound() {
		if (subRect.xMin < 0) subRect.xMin = 0;
		if (subRect.yMin < 0) subRect.yMin = 0;
		if (subRect.xMax >= this.grid.size.x) subRect.xMax = grid.size.x - 1;
		if (subRect.yMax >= this.grid.size.y) subRect.yMax = grid.size.y - 1;
	}

	public function iterate(): Vector2DRegionIterator<T> {
		return new Vector2DRegionIterator<T>(this);
	}

	/**
		if x / y is negative it will be taken from the end instead
	**/
	public function iterateRow(x: Int, y: Int, reversed: Bool = false): Vector2DRegionRowIterator<T> {
		if (x < 0) x += this.size.x;
		if (y < 0) y += this.size.y;
		return new Vector2DRegionRowIterator<T>(this, x, y, reversed);
	}

	/**
		if x / y is negative it will be taken from the end instead
	**/
	public function iterateColumn(x: Int, y: Int, reversed: Bool = false): Vector2DRegionColumnIterator<T> {
		if (x < 0) x += this.size.x;
		if (y < 0) y += this.size.y;
		return new Vector2DRegionColumnIterator<T>(this, x, y, reversed);
	}

	public function get(x: Int, y: Int): T {
		@:privateAccess
		if (!inBound(x, y)) return this.grid.nullValue;
		return this.grid.get(x + this.subRect.xMin, y + this.subRect.yMin);
	}

	public function set(x: Int, y: Int, value: T): T {
		@:privateAccess
		if (!inBound(x, y)) return this.grid.nullValue;
		this.grid.set(x + this.subRect.xMin, y + this.subRect.yMin, value);
		return value;
	}

	public function inBound(x: Int, y: Int): Bool {
		return x >= 0 && y >= 0 && x < this.size.x && y < this.size.y;
	}

	/**
		You can never sub region something bigger than the original region
	**/
	public function subRegion(xMin: Int, yMin: Int, width: Int, height: Int): Vector2DRegion<T> {
		xMin = xMin + this.subRect.xMin;
		yMin = yMin + this.subRect.yMin;
		var region = new Recti(xMin, yMin, xMin + width - 1, yMin + height - 1);
		region = this.subRect.boundRect(region);
		return new Vector2DRegion(this.grid, region);
	}

	inline public function setAll(value: T) {
		for (pt => v in this.iterate()) this.set(pt.x, pt.y, value);
	}

	/**
		count the number of neighbouring cells that matches a function
	**/
	public function countAround(centerX: Int, centerY: Int, match: T->Bool): Int {
		var count = 0;
		inline function countValue(x: Int, y: Int) {
			count += match(get(centerX + x, centerY + y)) ? 1 : 0;
		}
		countValue(-1, -1);
		countValue(0, -1);
		countValue(1, -1);
		countValue(-1, 0);
		countValue(1, 0);
		countValue(-1, 1);
		countValue(0, 1);
		countValue(1, 1);
		return count;
	}

	public function countAdjacent(centerX: Int, centerY: Int, match: T->Bool): Int {
		var count = 0;
		inline function countValue(x: Int, y: Int) {
			count += match(get(centerX + x, centerY + y)) ? 1 : 0;
		}
		countValue(0, -1);
		countValue(-1, 0);
		countValue(1, 0);
		countValue(0, 1);
		return count;
	}
}
