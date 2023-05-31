package zf.ui.builder.components;

/**
	Show the underlying object if a key in the context is true

	Tue 13:20:57 30 May 2023
	Struct is not implemented.
	Honestly, there might not be any need to implement it for struct, since we can already do it via code
	if we are using struct.
**/
class If extends zf.ui.builder.Component {
	public function new() {
		super("if");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);
		final boolKey = conf.getString("boolKey");
		if (boolKey == null) return null;

		try {
			final shouldShow: Bool = cast context.data.get(boolKey);
			if (shouldShow == false) return null;
			final item = element.firstElement();
			final object = context.makeObjectFromXMLElement(item);
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
