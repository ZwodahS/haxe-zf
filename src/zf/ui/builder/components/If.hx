package zf.ui.builder.components;

/**
	Show the underlying object if a key in the context is true

	# Attributes
	- boolKey=String
		get a bool from context. if it returns true, then the first element will be shown.
**/
class If extends Component {
	public function new() {
		super("if");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final boolKey = conf.getString("boolKey");
		if (boolKey == null) return null;

		try {
			final shouldShow: Bool = cast context.data.get(boolKey);
			if (shouldShow == false) return null;
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
