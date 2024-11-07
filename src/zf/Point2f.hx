package zf;

import zf.serialise.Serialisable;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
#if !macro @:build(zf.macros.Serialise.build()) #end
class Point2fImpl implements Serialisable implements Disposable {
	@:serialise @:dispose public var x: Float = 0;
	@:serialise @:dispose public var y: Float = 0;

	public var unit(get, never): Point2f;

	public function get_unit(): Point2f {
		// return a copy of the unit vector for this point
		final pt: Point2fImpl = this.clone();
		return pt.normalize();
	}

	public var abs(get, never): Point2f;

	public function get_abs(): Point2f {
		return Point2fImpl.alloc(hxd.Math.abs(this.x), hxd.Math.abs(this.y));
	}

	public var rad(get, set): Float;

	public function get_rad(): Float {
		return hxd.Math.atan2(this.y, this.x);
	}

	public function set_rad(r: Float): Float {
		final mag = hxd.Math.sqrt(hxd.Math.pow(this.x, 2) + hxd.Math.pow(this.y, 2));
		this.x = Math.cos(r) * mag;
		this.y = Math.sin(r) * mag;
		return r;
	}

	public var mag(get, set): Float;

	inline public function get_mag(): Float {
		return hxd.Math.sqrt(hxd.Math.pow(this.x, 2) + hxd.Math.pow(this.y, 2));
	}

	inline public function set_mag(m: Float): Float {
		// get the current mag
		final c = hxd.Math.sqrt(hxd.Math.pow(this.x, 2) + hxd.Math.pow(this.y, 2));
		this.x *= (1 / c * m);
		this.y *= (1 / c * m);
		return m;
	}

	function new() {}

	public function setX(x: Float): Point2fImpl {
		this.x = x;
		return this;
	}

	public function setY(y: Float): Point2fImpl {
		this.y = y;
		return this;
	}

	public function set(x: Float, y: Float): Point2fImpl {
		this.x = x;
		this.y = y;
		return this;
	}

	public function setPoint(pt: Point2f): Point2fImpl {
		this.x = pt.x;
		this.y = pt.y;
		return this;
	}

	inline public function clone(): Point2fImpl {
		return Point2fImpl.alloc(this.x, this.y);
	}

	public function toString(): String {
		return '{$x,$y}';
	}

	public function normalize(): Point2f {
		final mag = hxd.Math.sqrt(hxd.Math.pow(this.x, 2) + hxd.Math.pow(this.y, 2));
		this.x *= (1 / mag);
		this.y *= (1 / mag);
		return this;
	}

	public function distance(point: Point2f): Float {
		return distanceXY(point.x, point.y);
	}

	public function distanceXY(x: Float, y: Float): Float {
		return hxd.Math.sqrt(hxd.Math.pow(this.x - x, 2) + hxd.Math.pow(this.y - y, 2));
	}

	public static function alloc(x: Float, y: Float): Point2fImpl {
		final pt = Point2fImpl.__alloc__();
		pt.x = x;
		pt.y = y;
		return pt;
	}
}

@:forward abstract Point2f(Point2fImpl) from Point2fImpl to Point2fImpl {
	/**
		proxy this as min / max
	**/
	public var min(get, set): Float;

	inline public function get_min(): Float {
		return this.x;
	}

	inline public function set_min(v: Float): Float {
		return this.x = v;
	}

	public var max(get, set): Float;

	inline public function get_max(): Float {
		return this.y;
	}

	inline public function set_max(v: Float): Float {
		return this.y = v;
	}

	/**
		Difference between the 2 value, useful when we using this as min / max
	**/
	public var diff(get, never): Float;

	inline public function get_diff(): Float {
		return this.y - this.x;
	}

	public function new(x: Float = 0, y: Float = 0) {
		this = Point2fImpl.alloc(x, y);
	}

	public static function alloc(x: Float = 0, y: Float = 0): Point2f {
		return Point2fImpl.alloc(x, y);
	}

	@:from
	public static function fromArrayFloat(arr: Array<Float>): Point2f {
		return Point2fImpl.alloc(arr.length > 0 ? arr[0] : 0, arr.length > 1 ? arr[1] : 0);
	}

	@:to
	public function toArrayFloat(): Array<Float> {
		return [this.x, this.y];
	}

	@:to
	public function toh2dPoint(): h2d.col.Point {
		return new h2d.col.Point(this.x, this.y);
	}

	@:from
	public static function fromh2dPoint(p: h2d.col.Point): Point2f {
		return Point2f.alloc(p.x, p.y);
	}

	@:op(A += B)
	public function add(rhs: Point2f): Point2f {
		this.x += rhs.x;
		this.y += rhs.y;
		return this;
	}

	@:op(A + B)
	public function _add(rhs: Point2f): Point2f {
		return Point2fImpl.alloc(this.x + rhs.x, this.y + rhs.y);
	}

	@:op(A -= B)
	public function sub(rhs: Point2f): Point2f {
		this.x -= rhs.x;
		this.y -= rhs.y;
		return this;
	}

	@:op(A - B)
	public function _sub(rhs: Point2f): Point2f {
		return Point2fImpl.alloc(this.x - rhs.x, this.y - rhs.y);
	}

	@:op(A *= B)
	public function scale(rhs: Float): Point2f {
		this.x *= rhs;
		this.y *= rhs;
		return this;
	}

	@:op(A * B)
	public function _scale(rhs: Float): Point2f {
		return Point2fImpl.alloc(this.x * rhs, this.y * rhs);
	}

	@:op(A == B)
	public function _equal(rhs: Point2f): Bool {
		return this.x == rhs.x && this.y == rhs.y;
	}
}
/**
	Thu 12:53:58 07 Nov 2024
	Convert Point2f to pooled object
**/
