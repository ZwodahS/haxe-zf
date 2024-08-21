package tests.zf.classbuilder;

typedef Object1Conf = {
	public var ?x: Int;
}

typedef Object1ConfConf = {
	public var ?y: Int;
	public var ?z: Int;
}

#if !macro @:build(zf.macros.ClassBuilder.build()) #end
class Object1 {

	@:forward(["x"])
	public var conf: Object1Conf;

	@:forward public var confconf: Object1ConfConf;

	@:forward public var object2: Object2;

	public function new(conf: Object1Conf, confconf: Object1ConfConf) {
		this.conf = conf;
		this.confconf = confconf;
	}
}
