package zf.ui.builder.components;

/**
	Draw a line below a object, usually a text

	# Attributes
	- color=String -> context.builder.getColor(colorString)
	- spacing=Int
**/
class Underline extends zf.ui.builder.Component {
	public function new() {
		super("underline");
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): h2d.Object {
		final conf = zf.Access.struct(s);

		final colorString = conf.getString("color");
		var color: Color = 0xFF000000;
		if (colorString != null) {
			color = context.builder.parseColorString(colorString);
		}

		final object = new h2d.Flow();
		object.layout = Vertical;
		object.verticalSpacing = 3;
		object.horizontalAlign = Left;

		final firstElement = conf.get("item");
		if (firstElement != null) {
			final o = context.makeObjectFromStruct(firstElement);
			if (o == null) return object;
			object.addChild(o);
			final line = context.builder.fromColor(color, Std.int(o.getSize().width) + 3, 1);
			object.addChild(line);
		}
		return object;
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);

		final colorString = conf.getString("color");
		var color: Color = 0xFF000000;
		if (colorString != null) {
			color = context.builder.getColor(colorString) ?? context.builder.parseColorString(colorString);
		}

		final object = new h2d.Flow();
		object.layout = Vertical;
		var spacing = 3;
		if (conf.getInt("spacing") != null) spacing = conf.getInt("spacing");
		object.verticalSpacing = spacing;
		object.horizontalAlign = Left;

		final firstElement = element.firstElement();
		if (firstElement != null) {
			final o = context.makeObjectFromXMLElement(firstElement);
			if (o == null) return object;
			object.addChild(o);
			final line = context.builder.fromColor(color, Std.int(o.getSize().width) + 3, 1);
			object.addChild(line);
		}
		return object;
	}
}
