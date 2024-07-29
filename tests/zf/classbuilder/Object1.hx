package tests.zf.classbuilder;

typedef Object1Conf = {
	public var ?x: Int;
}

#if !macro @:build(zf.macros.ClassBuilder.build()) #end
class Object1 {

	@forward(["x"])
	public var conf: Object1Conf;

	public function new(conf: Object1Conf) {
		this.conf = conf;
	}
}
