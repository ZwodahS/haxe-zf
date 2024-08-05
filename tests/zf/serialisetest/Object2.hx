package tests.zf.serialisetest;

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object2 implements Identifiable implements Serialisable {

	public var id: String;
	public function identifier(): String {
		return this.id;
	}

	public function new(id: String) {
		this.id = id;
	}
}
