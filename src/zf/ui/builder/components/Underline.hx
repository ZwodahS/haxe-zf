package zf.ui.builder.components;

/**
	Draw a line below a object, usually a text

	# Attributes
	- color=String -> context.builder.getColor(colorString)
	- spacing=Int
**/
class Underline extends Component {
	public function new() {
		super("underline");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
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
			final o = context.build(firstElement)?.object;
			if (o != null) {
				object.addChild(o);
				final line = context.builder.fromColor(color, Std.int(o.getSize().width) + 3, 1);
				object.addChild(line);
			}
		}
		return {object: object};
	}
}
