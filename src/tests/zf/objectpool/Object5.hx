package tests.zf.objectpool;

using zf.ds.ArrayExtensions;

enum EValue {
	V1;
	V2;
}

#if !macro @:build(zf.macros.ObjectPool.addObjectPool()) #end
class Object5 implements Disposable {
	@dispose("set", null) public var object1: Object1;
	@dispose("set") public var xInt: Int = 0;
	@dispose("func", "clear") public var xArr: Array<Int>;
	@dispose public var xInt2: Int = 5;
	@dispose public var eValue: EValue = V1;
	@dispose public var f1: (Int, Int) -> Int = null;
	@dispose public var objNoDispose: ObjectNoDispose = null;

	// these 3 cases will generate warnings
	@dispose public var obj1: Object1 = null;
	@dispose public var obj1Arr1: Array<Object1>;
	@dispose public var obj1Arr2: Array<Object1> = null;

	function new() {
		this.xArr = [];
	}

	// ---- Object pooling Methods ----
	public function dispose() {
		__dispose__();
	}

	public static function alloc(): Object5 {
		final object = Object5.__alloc__();

		return object;
	}
}
