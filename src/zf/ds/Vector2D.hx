package zf.ds;

import haxe.ds.Vector;

/**
	This provides a 2D Vector by wrapping around a Vector
**/
@:access(zf.ds.ReadOnlyVector2D)
class Vector2DIteratorXY<T> {
	var data: ReadOnlyVector2D<T>;
	var currX: Int;
	var currY: Int;
	var point: Point2i;

	public function new(data: ReadOnlyVector2D<T>) {
		this.data = data;
		this.currX = 0;
		this.currY = 0;
		this.point = new Point2i();
	}

	public function hasNext(): Bool {
		return (this.currX < this.data.size.x && this.currY < this.data.size.y);
	}

	public function next(): {key: Point2i, value: T} {
		var returnValue = {
			key: this.point,
			value: this.data.data[data.pos(this.currX, this.currY)],
		}
		this.point.x = this.currX;
		this.point.y = this.currY;
		if (this.currY == this.data.size.y - 1) {
			this.currY = 0;
			this.currX += 1;
		} else {
			this.currY += 1;
		}
		return returnValue;
	}
}

@:access(zf.ds.ReadOnlyVector2D)
class Vector2DIteratorYX<T> {
	var data: ReadOnlyVector2D<T>;
	var currX: Int;
	var currY: Int;
	var pos: Int = 0;

	var point: Point2i;

	public function new(data: ReadOnlyVector2D<T>) {
		this.data = data;
		this.currX = 0;
		this.currY = 0;
		this.point = new Point2i();
	}

	public function hasNext(): Bool {
		return (this.currX < this.data.size.x && this.currY < this.data.size.y);
	}

	public function next(): {key: Point2i, value: T} {
		this.point.x = this.currX;
		this.point.y = this.currY;
		var returnValue = {
			key: this.point,
			value: this.data.data[pos], // this works because we know how Vector2D stores the data
		}
		if (this.currX == this.data.size.x - 1) {
			this.currX = 0;
			this.currY += 1;
		} else {
			this.currX += 1;
		}
		pos += 1;
		return returnValue;
	}
}

@:access(zf.ds.ReadOnlyVector2D)
class LinearIterator<T> {
	var data: ReadOnlyVector2D<T>;
	var curr: Int;

	public function new(data: ReadOnlyVector2D<T>) {
		this.data = data;
		this.curr = 0;
	}

	public function hasNext(): Bool {
		return this.curr < this.data.data.length;
	}

	public function next(): T {
		if (this.curr >= this.data.data.length) return null;
		return this.data.data[curr++];
	}
}

class ReadOnlyVector2D<T> {
	/**
		A 2x3 (width * height)
		[
			0, 1
			2, 3
			4, 5
		]
		will be stored as [0, 1, 2, 3, 4, 5]
		There shouldn't be a need to know this when using this from outside.
	**/
	public var size(default, null): Point2i;

	var data: Vector<T>;
	var nullValue: T;

	public function toString(): String {
		var str = "";
		for (y in 0...this.size.y) {
			for (x in 0...this.size.x) {
				str += this.get(x, y) + " ";
			}
			str += "\n";
		}
		return str;
	}

	public function new(s: Point2i, nullValue: T, copy: Vector<T> = null) {
		this.size = s.copy();

		this.data = new Vector<T>(this.size.x * this.size.y);
		for (i in 0...data.length) {
			this.data[i] = nullValue;
		}
		if (copy != null) {
			for (i in 0...(hxd.Math.imin(this.data.length, copy.length))) {
				this.data[i] = copy[i];
			}
		}
	}

	inline public function get(x, y): T {
		if (!inBound(x, y)) return nullValue;
		return this.data[pos(x, y)];
	}

	inline function pos(x: Int, y: Int): Int { // return -1 if out of bound
		return x + (y * size.x);
	}

	public function inBound(x: Int, y: Int): Bool {
		return x >= 0 && x < this.size.x && y >= 0 && y < this.size.y;
	}

	public function iterator(): LinearIterator<T> {
		return new LinearIterator<T>(this);
	}

	/**
		iterate x then y
		essentially
		for (x in 0...size.x) {
			for (y in 0...size.y ) {
			}
		}
	**/
	public function iterateXY(): Vector2DIteratorXY<T> {
		return new Vector2DIteratorXY<T>(this);
	}

	/**
		iterate Y then X
		essentially
		for (y in 0...size.y) {
			for (x in 0...size.x) {
			}
		}
	**/
	public function iterateYX(): Vector2DIteratorYX<T> {
		return new Vector2DIteratorYX<T>(this);
	}

	public function copy(): Vector2D<T> {
		return new Vector2D<T>(this.size, this.nullValue, this.data);
	}

	/**
		Get items adjacent to this position

		@param x
		@param y

		return items in this order
		left (x-1, y), right (x+1, y), up (x, y-1), down (x, y+1)
	**/
	public function getAdjacent(x: Int, y: Int): Array<T> {
		var arr: Array<T> = [];
		inline function _add(x0: Int, y0: Int) {
			var t = get(x0, y0);
			if (t != null) arr.push(t);
		}
		_add(x - 1, y);
		_add(x + 1, y);
		_add(x, y - 1);
		_add(x, y + 1);
		return arr;
	}

	/**
		Get items around this position

		@param x
		@param y
		@param includeSelf include the item in the position
	**/
	public function getAround(x: Int, y: Int, includeSelf: Bool = false): Array<T> {
		var arr: Array<T> = [];
		inline function _add(x0: Int, y0: Int) {
			var t = get(x0, y0);
			if (t != null) arr.push(t);
		}
		for (x0 in x - 1...x + 2) {
			for (y0 in y - 1...y + 2) {
				if (x0 == x && y0 == y && !includeSelf) continue;
				_add(x0, y0);
			}
		}
		return arr;
	}
}

class Vector2D<T> extends ReadOnlyVector2D<T> {
	inline public function set(x, y, value: T) {
		if (!inBound(x, y)) return;
		this.data[pos(x, y)] = value;
	}

	// https://stackoverflow.com/questions/18034805/rotate-mn-matrix-90-degrees
	public function rotateCCW(): Vector2D<T> {
		var newLengthX = this.size.y;
		var newLengthY = this.size.x;
		var copy = new Vector<T>(this.data.length);
		var x1 = 0;
		var y1 = 0;
		var x0 = this.size.x - 1;
		while (x0 >= 0) {
			x1 = 0;
			for (y0 in 0...this.size.y) {
				copy[(y1 * newLengthX) + x1] = this.data[pos(x0, y0)];
				x1 += 1;
			}
			x0 -= 1;
			y1 += 1;
		}
		for (i in 0...data.length) {
			data[i] = copy[i];
		}
		this.size.x = newLengthX;
		this.size.y = newLengthY;
		return this;
	}

	public function rotateCW(): Vector2D<T> {
		var newLengthX = this.size.y;
		var newLengthY = this.size.x;
		var copy = new Vector<T>(this.data.length);
		var x1 = 0;
		var y1 = 0;
		var x0 = this.size.x - 1;
		for (x0 in 0...this.size.x) {
			x1 = newLengthX - 1;
			for (y0 in 0...this.size.y) {
				copy[(y1 * newLengthX) + x1] = this.data[pos(x0, y0)];
				x1 -= 1;
			}
			y1 += 1;
		}
		for (i in 0...data.length) {
			data[i] = copy[i];
		}
		this.size.x = newLengthX;
		this.size.y = newLengthY;
		return this;
	}

	public function flipHorizontal(): Vector2D<T> {
		// flip will not change size
		inline function swap(y: Int, x1: Int, x2: Int) {
			var p1 = pos(x1, y);
			var p2 = pos(x2, y);
			var old = data[p1];
			data[p1] = data[p2];
			data[p2] = old;
		}
		for (y in 0...this.size.y) {
			for (x in 0...Std.int(this.size.x / 2)) {
				swap(y, x, this.size.x - 1 - x);
			}
		}
		return this;
	}

	public function flipVertical(): Vector2D<T> {
		// flip will not change size
		inline function swap(x: Int, y1: Int, y2: Int) {
			var p1 = pos(x, y1);
			var p2 = pos(x, y2);
			var old = data[p1];
			data[p1] = data[p2];
			data[p2] = old;
		}
		for (x in 0...this.size.x) {
			for (y in 0...Std.int(this.size.y / 2)) {
				swap(x, y, this.size.y - 1 - y);
			}
		}
		return this;
	}

	inline public function setAll(value: T) {
		for (i in 0...this.data.length) this.data[i] = value;
	}

	public function getRegion(): Vector2DRegion<T> {
		return new Vector2DRegion(this);
	}
}
