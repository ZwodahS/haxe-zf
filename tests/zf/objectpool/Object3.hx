package tests.zf.objectpool;

using zf.ds.ArrayExtensions;

#if !macro @:build(zf.macros.ObjectPool.addObjectPool()) #end
class Object3 implements Disposable {
	@:dispose public var object1: Object1;
	@:dispose("set", 0) public var xInt: Int = 0;
	@:dispose("func", "clear") public var xArr: Array<Int>;

	function new() {
		this.xArr = [];
	}

	// ---- Object pooling Methods ----
	public function dispose() {
		__dispose__();
	}

	public static function alloc(): Object3 {
		final object = Object3.__alloc__();

		return object;
	}
}
