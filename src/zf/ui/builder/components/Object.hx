package zf.ui.builder.components;

typedef ObjectConf = {
	public var object: h2d.Object;
}

/**
	Display a object from the context

	# Attributes
	- object=String
**/
class Object extends Component {
	public function new() {
		super("object");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final objectKey = conf.getString("object");
		try {
			final object: h2d.Object = cast context.data.get(objectKey);
			return {object: object};
		} catch (e) {
			return null;
		}
	}
}
