package zf;

/**
	Note that Recti behaves differently from Rectf, due to the discrete nature of Recti

	For example, right in this case denote the right most position, rather than the first position after the right
	i.e. xMin = 0, xMax = 2, will be the same as left == 0, right == 2,

	xDiff also behaves differently from width
	xDiff in the above case will return 2, while width will return 3
	The way to think of this is xDiff and yDiff is the difference between xMin and xMax.
	Width is the number of 'value' in the x-axis.
	The same applies to the y axis.

	area will behaves like width * height, i.e. number of square in the rect

	Additional notes on the Getter.
		1. The following pair are guaranteed to be equal
		- xMin == left
		- yMin == top
		- xMax == right
		- yMax == bottom

	Additional notes on Setter.
		Each group of setters have different behaviors.
		- xMin/xMax/yMin/yMax will modify the underlying value of the rectangle
		- left/right/top/bottom will modify the value, while preserving the width/height
		- width/height will preserve xMin/yMin, while modifying xMax/yMax

**/
abstract Recti(Array<Int>) from Array<Int> to Array<Int> {
	public var xMin(get, set): Int;
	public var xMax(get, set): Int;
	public var yMin(get, set): Int;
	public var yMax(get, set): Int;

	public var left(get, set): Int;
	public var right(get, set): Int;
	public var top(get, set): Int;
	public var bottom(get, set): Int;

	public var xDiff(get, never): Int;
	public var yDiff(get, never): Int;

	public var width(get, set): Int;
	public var height(get, set): Int;

	public var area(get, never): Int;

	public var points(get, never): Array<Point2i>;

	public function new(xMin: Int = 0, yMin: Int = 0, xMax: Int = 0, yMax: Int = 0) {
		this = [xMin, yMin, xMax, yMax];
	}

	public function set_xMin(xMin: Int): Int {
		this[0] = xMin;
		return this[0];
	}

	public function get_xMin(): Int {
		return this[0];
	}

	public function set_xMax(xMax: Int): Int {
		this[2] = xMax;
		return this[2];
	}

	public function get_xMax(): Int {
		return this[2];
	}

	public function set_yMin(yMin: Int): Int {
		this[1] = yMin;
		return this[1];
	}

	public function get_yMin(): Int {
		return this[1];
	}

	public function set_yMax(yMax: Int): Int {
		this[3] = yMax;
		return this[3];
	}

	public function get_yMax(): Int {
		return this[3];
	}

	public function set_left(v: Int): Int {
		var w = this[2] - this[0];
		this[0] = v;
		this[2] = v + w;
		return v;
	}

	public function get_left(): Int {
		return this[0];
	}

	public function set_right(v: Int): Int {
		var w = this[2] - this[0];
		this[0] = v - w;
		this[2] = v;
		return v;
	}

	public function get_right(): Int {
		return this[2];
	}

	public function set_top(v: Int): Int {
		var w = this[3] - this[1];
		this[1] = v;
		this[3] = v + w;
		return v;
	}

	public function get_top(): Int {
		return this[1];
	}

	public function set_bottom(v: Int): Int {
		var w = this[3] - this[1];
		this[1] = v - w;
		this[3] = v;
		return v;
	}

	public function get_bottom(): Int {
		return this[3];
	}

	public function intersect(rect: Recti): Bool {
		if (this[0] > rect.xMax || rect.xMin > this[2]) {
			return false;
		}
		if (this[1] > rect.yMax || rect.yMin > this[3]) {
			return false;
		}
		return true;
	}

	public function contains(x: Int, y: Int): Bool {
		// xMin <= x && x <= xMax && yMin <= y && y <= yMax;
		return this[0] <= x && x <= this[2] && this[1] <= y && y <= this[3];
	}

	public function get_xDiff(): Int {
		return this[2] - this[0];
	}

	public function get_yDiff(): Int {
		return this[3] - this[1];
	}

	public function get_width(): Int {
		return this[2] - this[0] + 1;
	}

	public function set_width(w: Int): Int {
		this[2] = this[0] + w - 1;
		return w;
	}

	public function get_height(): Int {
		return this[3] - this[1] + 1;
	}

	public function set_height(h: Int): Int {
		this[3] = this[1] + h - 1;
		return h;
	}

	public function get_area(): Int {
		return (width * height);
	}

	@:op(A == B)
	public function _equal(rhs: Recti): Bool {
		return this[0] == rhs.xMin && this[1] == rhs.yMin && this[2] == rhs.xMax && this[3] == rhs.yMax;
	}

	public function clone(): Recti {
		return [this[0], this[1], this[2], this[3]];
	}

	public function copy(): Recti {
		return [this[0], this[1], this[2], this[3]];
	}

	/**
		Force Place the input rect within this rect.
		if input rect is outside of this rect then a size 1,1 rect is returned
	**/
	public function boundRect(rect: Recti): Recti {
		var recti: Recti = rect.clone();

		if (recti.xMin < this[0]) recti.xMin = this[0];
		if (recti.yMin < this[1]) recti.yMin = this[1];
		if (recti.xMax > this[2]) recti.xMax = this[2];
		if (recti.yMax > this[3]) recti.yMax = this[3];

		if (recti.xMin > recti.xMax) {
			if (recti.xMax < this[0]) {
				recti.xMax = recti.xMin;
			} else {
				recti.xMin = recti.xMax;
			}
		}
		if (recti.yMin > recti.yMax) {
			if (recti.yMax < this[2]) {
				recti.yMax = recti.yMin;
			} else {
				recti.yMin = recti.yMax;
			}
		}

		return recti;
	}

	public function get_points(): Array<Point2i> {
		var points: Array<Point2i> = [];
		for (y in this[1]...this[3] + 1) {
			for (x in this[0]...this[2] + 1) {
				points.push([x, y]);
			}
		}
		return points;
	}

	public function splitHorizontal(leftWidth: Int): Array<Recti> {
		var thisRect: Recti = this;
		if (leftWidth > thisRect.width) leftWidth = thisRect.width;
		if (leftWidth == 0) return [null, thisRect.clone()];
		var r0 = new Recti(thisRect.xMin, thisRect.yMin, thisRect.xMin + leftWidth - 1, thisRect.yMax);
		var r1 = leftWidth == thisRect.width ? null : new Recti(r0.xMax + 1, r0.yMin, thisRect.xMax, r0.yMax);
		return [r0, r1];
	}

	public function splitVertical(topHeight: Int): Array<Recti> {
		var thisRect: Recti = this;
		if (topHeight > thisRect.height) topHeight = thisRect.height;
		if (topHeight == 0) return [null, thisRect.clone()];
		var r0 = new Recti(thisRect.xMin, thisRect.yMin, thisRect.xMax, thisRect.yMin + topHeight - 1);
		var r1 = topHeight == thisRect.height ? null : new Recti(r0.xMin, r0.yMax + 1, r0.xMax,
			thisRect.yMax);
		return [r0, r1];
	}

	/**
		Expand the rect by amt in all direction
	**/
	public function expand(amt: Int): Recti {
		this[0] -= amt;
		this[1] -= amt;
		this[2] += amt;
		this[3] += amt;
		return this;
	}

	public function shrink(amt: Int): Recti {
		this[0] += amt;
		this[1] += amt;
		this[2] -= amt;
		this[3] -= amt;
		if (this[0] > this[2]) this[2] = this[0];
		if (this[1] > this[3]) this[3] = this[1];
		return this;
	}
}
