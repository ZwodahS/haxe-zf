package tests.zf.objectpool;

using zf.ds.ArrayExtensions;

#if !macro @:build(zf.macros.ObjectPool.addObjectPool()) #end
class Object2 implements Disposable {
	@dispose public var object1: Object1;
	@dispose public var xInt: Int = 0;
	@dispose("func", "clear") public var xArr: Array<Int>;

	function new() {
		this.xArr = [];
	}

	// ---- Object pooling Methods ----

	public static function alloc(): Object2 {
		final object = Object2.__alloc__();

		return object;
	}
}
