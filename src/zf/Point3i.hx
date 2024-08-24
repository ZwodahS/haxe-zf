package zf;

/**
	@stage:stable
**/
abstract Point3i(Array<Int>) from Array<Int> to Array<Int> {
	public var x(get, set): Int;
	public var y(get, set): Int;
	public var z(get, set): Int;

	inline public function new(x: Int = 0, y: Int = 0, z: Int = 0) {
		this = [x, y, z];
	}

	public function toString(): String {
		return '{$x,$y,$z}';
	}

	@:op(A += B)
	public function add(rhs: Array<Int>): Point3i {
		this[0] += rhs[0];
		this[1] += rhs[1];
		this[2] += rhs[2];
		return this;
	}

	@:op(A + B)
	public function _add(rhs: Array<Int>): Point3i {
		return new Point3i(this[0] + rhs[0], this[1] + rhs[1], this[2] + rhs[2]);
	}

	@:op(A -= B)
	public function sub(rhs: Array<Int>): Point3i {
		this[0] -= rhs[0];
		this[1] -= rhs[1];
		this[2] -= rhs[2];
		return this;
	}

	@:op(A - B)
	public function _sub(rhs: Array<Int>): Point3i {
		return new Point3i(this[0] - rhs[0], this[1] - rhs[1], this[2] - rhs[2]);
	}

	@:op(A == B)
	public function _equal(rhs: Point3i): Bool {
		return this[0] == rhs.x && this[1] == rhs.y && this[2] == rhs.z;
	}

	public function update(rhs: Point3i): Point3i {
		this[0] = rhs[0];
		this[1] = rhs[1];
		this[2] = rhs[2];
		return this;
	}

	inline public function clone(): Point3i {
		return [this[0], this[1], this[2]];
	}

	inline public function get_x(): Int {
		return this[0];
	}

	inline public function set_x(v: Int): Int {
		return this[0] = v;
	}

	inline public function get_y(): Int {
		return this[1];
	}

	inline public function set_y(v: Int): Int {
		return this[1] = v;
	}

	inline public function get_z(): Int {
		return this[2];
	}

	inline public function set_z(v: Int): Int {
		return this[2] = v;
	}

	@:to
	public function toPoint2i(): Point2i {
		return new Point2i(this[0], this[1]);
	}

	@:to
	public function toPoint2f(): Point2f {
		return new Point2f(this[0], this[1]);
	}

	@:to
	public function toPoint3f(): Point3f {
		return new Point3f(this[0], this[1], this[2]);
	}
}
