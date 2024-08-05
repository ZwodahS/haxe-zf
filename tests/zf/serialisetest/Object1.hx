package tests.zf.serialisetest;

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object1 implements Serialisable {

	@serialise public var x: Int = 0;
	@serialise public var arrInt: Array<Int> = null;
	@serialise public var mapInt: Map<String, Int>;

	public function new () {}
}
