package tests.zf.objectpool;

interface O1 {}

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Object1 implements Disposable implements O1 {
	public var xInt: Int = 0;

	@dispose public var object5: Object5;

	function new() {}

	public function reset() {
		this.xInt = 0;
	}
}
