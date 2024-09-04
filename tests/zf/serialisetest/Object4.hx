package tests.zf.serialisetest;

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object4 implements Serialisable {

	@:serialise public var id: String;

	@:serialise public var o5: Object5;

	public function new(id: String) {
		this.id = id;
	}

	public static function empty() {
		return new Object4(null);
	}
}
