package zf.tui.templates;

typedef ObjectConf = {
	public var object: h2d.Object;
}

class Object extends zf.tui.Template {
	public function new() {
		super("object");
	}

	override public function make(c: Dynamic): h2d.Object {
		final conf: ObjectConf = c;
		return conf.object;
	}
}
