package zf.ui.builder.components;

typedef ObjectConf = {
	public var object: h2d.Object;
}

class Object extends Component {
	public function new() {
		super("object");
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: ObjectConf = c;
		return conf.object;
	}
}
