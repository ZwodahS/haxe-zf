package zf.ui.builder.components;

/**
	Show the underlying object if a key in the context does not exists

	# Attributes
	- existsKey=String
**/
class IfNotExists extends Component {
	public function new() {
		super("if-not-exists");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final existsKey = conf.getString("existsKey");
		if (existsKey == null) return null;

		try {
			final item = context.data.get(existsKey);
			if (item != null) return null;
			final item = element.firstElement();
			final object = context.build(item);
			// propagates all the attributes upward
			for (attr in item.attributes()) {
				element.set(attr, item.get(attr));
			}
			return object;
		} catch (e) {
			return null;
		}
	}
}
