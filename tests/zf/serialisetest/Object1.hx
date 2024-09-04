package tests.zf.serialisetest;

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object1 implements Serialisable {

	@:serialise public var x: Int = 0;
	@:serialise public var arrInt: Array<Int> = null;
	@:serialise public var mapInt: Map<String, Int>;
	@:serialise(null, true) public var o2: Object2 = null;
	@:serialise(null, false) public var o3: Object3 = null;
	@:serialise(null, true) public var arrO2: Array<Object2> = null;
	@:serialise public var arrO3: Array<Object3> = null;

	public function new () {}
}
