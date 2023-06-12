package zf.ui.builder.components;

/**
	Show the underlying object if a key in the context has item

	Tue 13:20:57 30 May 2023
	Struct is not implemented.
	Honestly, there might not be any need to implement it for struct, since we can already do it via code
	if we are using struct.
**/
class IfExists extends zf.ui.builder.Component {
	public function new() {
		super("if-exists");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);
		final existsKey = conf.getString("existsKey");
		if (existsKey == null) return null;

		try {
			final item = context.data.get(existsKey);
			if (item == null) return null;
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
