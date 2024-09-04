package tests.zf.serialisetest;

#if !macro @:build(zf.macros.Serialise.build()) #end
class Object5 implements Serialisable {

	@:serialise public var id: String;

	@:serialise public var o4: Object4;

	public function new(id: String) {
		this.id = id;
	}

	public static function empty() {
		return new Object5(null);
	}
}
