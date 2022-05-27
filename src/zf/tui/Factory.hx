package zf.tui;

class Factory {
	public var templates: Map<String, Template>;

	public function new() {
		this.templates = new Map<String, Template>();
		CompileTime.importPackage("zf.tui.templates");
		final classes = CompileTime.getAllClasses("zf.tui.templates", true, Template);
		for (c in classes) {
			register(Type.createInstance(c, []));
		}
	}

	@:deprecated
	public function createObject(conf: TemplateConf): h2d.Object {
		final t = this.templates[conf.type];
		if (t == null) {
			return new h2d.Object();
		}
		return t.make(conf.conf);
	}

	public function register(t: Template) {
		this.templates[t.type] = t;
		t.factory = this;
	}
}
