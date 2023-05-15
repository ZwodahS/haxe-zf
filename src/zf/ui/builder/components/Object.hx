package zf.ui.builder.components;

typedef ObjectConf = {
	public var object: h2d.Object;
}

/**
	@stage:stable
**/
class Object extends Component {
	public function new() {
		super("object");
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: ObjectConf = c;
		return conf.object;
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);
		final objectKey = conf.getString("object");
		try {
			final object: h2d.Object = cast context.data.get(objectKey);
			return object;
		} catch (e) {
			return null;
		}
	}
}
