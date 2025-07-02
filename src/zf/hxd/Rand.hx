package zf.hxd;

import zf.serialise.*;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Rand extends hxd.Rand implements Disposable implements zf.serialise.Serialisable {
	function new() {
		super(0);
	}

	public static function alloc(seed: Null<Int> = null): Rand {
		if (seed == null) seed = Std.random(0x7FFFFFFF);
		final r = __alloc__();
		r.init(seed);
		return r;
	}

	public function toStruct(context: SerialiseContext): Dynamic {
		return {seed1: this.seed, seed2: this.seed2};
	}

	public function loadStruct(context: SerialiseContext, data: Dynamic) {
		final d: DynamicAccess<Dynamic> = data;
		this.seed = d.get("seed1") ?? 0;
		this.seed2 = d.get("seed2") ?? 0;
		return this;
	}
}
