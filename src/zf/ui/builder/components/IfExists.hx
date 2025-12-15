package zf.ui.builder.components;

/**
	Show the underlying object if a key in the context has item

	# Attributes
	- existsKey=String
**/
class IfExists extends Component {
	public function new() {
		super("if-exists");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final existsKey = conf.getString("existsKey");
		if (existsKey == null) return null;

		try {
			final item = context.data.get(existsKey);
			if (item == null) return null;
			final item = element.firstElement();
			final object = context.build(item);
			// propagates all the attributes upward, necessary for layout.
			for (attr in item.attributes()) {
				element.set(attr, item.get(attr));
			}
			return object;
		} catch (e) {
			return null;
		}
	}
}
