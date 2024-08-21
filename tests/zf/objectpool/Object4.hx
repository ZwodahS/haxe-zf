package tests.zf.objectpool;

using zf.ds.ArrayExtensions;

class ParentObject {
	function new() {}

	public function dispose() {}
}

#if !macro @:build(zf.macros.ObjectPool.addObjectPool()) #end
class Object4 extends ParentObject implements Disposable {
	@:dispose public var object1: Object1;
	@:dispose("set", 0) public var xInt: Int = 0;
	@:dispose("func", "clear") public var xArr: Array<Int>;

	function new() {
		super();
		this.xArr = [];
	}

	// ---- Object pooling Methods ----

	public static function alloc(): Object3 {
		final object = Object3.__alloc__();

		return object;
	}
}
