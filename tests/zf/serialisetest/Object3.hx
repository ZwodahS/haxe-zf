package tests.zf.serialisetest;

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object3 implements Identifiable implements Serialisable {

	@:serialise public var id: String;
	public function identifier(): String {
		return this.id;
	}

	public function new(id: String) {
		this.id = id;
	}

	public static function empty() {
		return new Object3(null);
	}
}
