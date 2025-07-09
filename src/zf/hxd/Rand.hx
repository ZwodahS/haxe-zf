package zf.hxd;

import zf.serialise.*;

class Rand extends hxd.Rand implements Disposable implements zf.serialise.Serialisable {
	/**
		Can't use object pool macro here, because that previous extensions from using Rand, which I need.
		Build the object pooling manually
	**/
	static var __pool__: Rand = null;

	var __next__: Rand = null;

	/**
		A global rand to be used when we need a temporary one.
	**/
	static var _r: Rand;

	public static function r(): Rand {
		if (Rand._r == null) Rand._r = alloc();
		return Rand._r;
	}

	function new() {
		super(0);
	}

	public static function alloc(seed: Null<Int> = null): Rand {
		final rand: Rand = __alloc__();
		if (seed == null) seed = Std.random(0x7FFFFFFF);
		rand.init(seed);
		return rand;
	}

	static function __alloc__(): Rand {
		if (__pool__ != null) {
			final r = __pool__;
			__pool__ = r.__next__;
			r.__next__ = null;
			return r;
		} else {
			return new Rand();
		}
	}

	public function dispose() {
		this.__next__ = __pool__;
		__pool__ = this;
	}

	public function toStruct(context: SerialiseContext, struct: Dynamic = null): Dynamic {
		if (struct == null) struct = {};
		struct.seed1 = this.seed;
		struct.seed2 = this.seed2;
		return struct;
	}

	public function loadStruct(context: SerialiseContext, struct: Dynamic) {
		final d: DynamicAccess<Dynamic> = struct;
		this.seed = d.get("seed1") ?? 0;
		this.seed2 = d.get("seed2") ?? 0;
		return this;
	}
}
