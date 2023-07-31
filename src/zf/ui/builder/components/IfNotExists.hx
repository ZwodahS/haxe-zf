package zf.ui.builder.components;

class IfNotExists extends zf.ui.builder.Component {
	public function new() {
		super("if-not-exists");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);
		final existsKey = conf.getString("existsKey");
		if (existsKey == null) return null;

		try {
			final item = context.data.get(existsKey);
			if (item != null) return null;
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
