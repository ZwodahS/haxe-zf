package zf;

enum IntersectType {
	// assume that we call A.insectionDetail(B)
	None; // No intersection
	Inside; // A is inside B; B-min <= A-min < A-max <= B-max
	Contains; // A contains the full of B; A-min <= B-min < B-max <= A-max
	Negative; // A intersect on the negative side of B (left or top) A-min < B-min < A-max < B-max
	Positive; // A intersect on the positive side of B (right or top) B-min < A-min < B-max < A-max
	// if A and B is equal, A.interectionDetail(B) == B.intersectDetail(A) == Inside
}

@:structInit class IntersectDetail {
	// x and y will always be positive.
	public var x: Float;
	public var y: Float;
	public var xType: IntersectType;
	public var yType: IntersectType;
}

abstract Rectf(Array<Float>) from Array<Float> to Array<Float> {
	public var xMin(get, set): Float;
	public var xMax(get, set): Float;
	public var yMin(get, set): Float;
	public var yMax(get, set): Float;

	// setting x and y will preserve the width / height
	public var x(get, set): Float;
	public var y(get, set): Float;
	// setting right and bottom will preserve the width / height
	public var right(get, set): Float;
	public var bottom(get, set): Float;
	// setting the width and height will preserve x and y, and change xMax / yMax
	public var width(get, set): Float;
	public var height(get, set): Float;

	public function new(xMin: Float = 0, yMin: Float = 0, xMax: Float = 0, yMax: Float = 0) {
		this = [xMin, yMin, xMax, yMax];
	}

	public function set_xMin(xMin: Float): Float {
		this[0] = xMin;
		return this[0];
	}

	public function get_xMin(): Float {
		return this[0];
	}

	public function set_xMax(xMax: Float): Float {
		this[2] = xMax;
		return this[2];
	}

	public function get_xMax(): Float {
		return this[2];
	}

	public function set_yMin(yMin: Float): Float {
		this[1] = yMin;
		return this[1];
	}

	public function get_yMin(): Float {
		return this[1];
	}

	public function set_yMax(yMax: Float): Float {
		this[3] = yMax;
		return this[3];
	}

	public function get_yMax(): Float {
		return this[3];
	}

	public function get_width(): Float {
		return this[2] - this[0];
	}

	public function set_width(v: Float): Float {
		this[2] = this[0] + v;
		return v;
	}

	public function get_height(): Float {
		return this[3] - this[1];
	}

	public function set_height(v: Float): Float {
		this[3] = this[1] + v;
		return v;
	}

	public function set_x(v: Float): Float {
		var w = this[2] - this[0];
		this[0] = v;
		this[2] = v + w;
		return v;
	}

	public function get_x(): Float {
		return this[0];
	}

	public function set_y(v: Float): Float {
		var w = this[3] - this[1];
		this[1] = v;
		this[3] = v + w;
		return v;
	}

	public function get_y(): Float {
		return this[1];
	}

	public function get_right(): Float {
		return this[2];
	}

	public function set_right(v: Float): Float {
		var w = this[2] - this[0];
		this[0] = v - w;
		this[2] = v;
		return v;
	}

	public function get_bottom(): Float {
		return this[3];
	}

	public function set_bottom(v: Float): Float {
		var w = this[3] - this[1];
		this[1] = v - w;
		this[3] = v;
		return v;
	}

	public function intersect(rect: Rectf): Bool {
		if (this[0] >= rect.xMax || rect.xMin >= this[2]) {
			return false;
		}
		if (this[1] >= rect.yMax || rect.yMin >= this[3]) {
			return false;
		}
		return true;
	}

	public function intersectDetail(rect: Rectf): IntersectDetail {
		var xDetail = intersectType(this[0], this[2], rect.xMin, rect.xMax);
		if (xDetail.type == None) return {
			x: 0,
			y: 0,
			xType: None,
			yType: None
		};
		var yDetail = intersectType(this[1], this[3], rect.yMin, rect.yMax);
		if (xDetail.type == None) return {
			x: 0,
			y: 0,
			xType: None,
			yType: None
		};
		return {
			x: xDetail.amount,
			y: yDetail.amount,
			xType: xDetail.type,
			yType: yDetail.type
		};
	}

	static function intersectType(aMin: Float, aMax: Float, bMin: Float,
			bMax): {amount: Float, type: IntersectType} {
		if (aMin >= bMax || bMin >= aMax) return {amount: 0, type: None};
		// Diagram, we will use a0, a1, b0, b1 to show what each statement does
		// Assumption, a1 >= a0, b1 >= b0
		if (bMin <= aMin) { // test for b0 a0
			// this only have 2 cases, Inside or Position
			if (aMax <= bMax) { // b0 a0 a1 b1
				// a is inside b.
				return {amount: aMax - aMin, type: Inside};
			} else { // b0 a0 b1 a1
				// a intersect on the positive side of b
				return {amount: bMax - aMin, type: Positive};
			}
		} else if (aMin <= bMin) { // test for a0 b0
			if (bMax <= aMax) { // a0 b0 b1 a1
				return {amount: bMax - bMin, type: Contains};
			} else { // a0 b0 a1 b1
				return {amount: aMax - bMin, type: Negative};
			}
		} // there should never be a else, since on will be
		return {amount: 0, type: None};
	}

	public function intersectWithBorder(rect: Rectf): Bool {
		if (this[0] > rect.xMax || rect.xMin > this[2]) {
			return false;
		}
		if (this[1] > rect.yMax || rect.yMin > this[3]) {
			return false;
		}
		return true;
	}

	/**
		Place the input rect within this rect.

		If any dimensional of thisRect is smaller than rect, the input rect is returned
	**/
	public function alignRect(rect: Rectf): Rectf {
		var thisRect: Rectf = this;
		var details = rect.intersectDetail(thisRect);
		var outRect = rect.clone();
		if (thisRect.width <= rect.width || thisRect.height <= rect.height) return outRect;
		switch (details.xType) {
			case None:
				outRect.x = thisRect.x;
			case Inside: // do nothing
			case Contains: // do nothing
			case Negative:
				outRect.x = thisRect.x;
			case Positive:
				outRect.right = thisRect.right;
		}

		switch (details.yType) {
			case None:
				outRect.y = thisRect.y;
			case Inside: // do nothing
			case Contains: // do nothing
			case Negative:
				outRect.y = thisRect.y;
			case Positive:
				outRect.bottom = thisRect.bottom;
		}
		return outRect;
	}

	public function contains(point: Point2f): Bool {
		return (this[0] <= point.x && this[2] >= point.x && this[1] <= point.y && this[3] >= point.y);
	}

	public function clone(): Rectf {
		return [this[0], this[1], this[2], this[3]];
	}

	public function toString(): String {
		return 'x: [${this[0]}, ${this[2]}], y: [${this[1]}, ${this[3]}]';
	}
}
