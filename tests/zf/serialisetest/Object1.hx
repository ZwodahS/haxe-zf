package tests.zf.serialisetest;

typedef A = {
	public var ?aInt: Int;
	public var ?aArrInt: Array<Int>;
	public var ?aString: String;
	public var ?aArrString: Array<String>;
	public var ?aFloat: Float;
	public var ?aArrFloat: Array<Float>;
}

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object1 implements Serialisable {

	@:serialise public var x: Int = 0;
	@:serialise public var arrInt: Array<Int> = null;
	@:serialise public var mapInt: Map<String, Int>;
	@:serialise(null, true) public var o2: Object2 = null;
	@:serialise(null, false) public var o3: Object3 = null;
	@:serialise(null, true) public var arrO2: Array<Object2> = null;
	@:serialise public var arrO3: Array<Object3> = null;

	@:serialise public var a: A = null;

	public function new () {}
}
