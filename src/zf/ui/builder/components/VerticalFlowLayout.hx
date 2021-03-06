package zf.ui.builder.components;

private typedef LayoutConf = {
	public var ?paddingTop: Int;
}

typedef VerticalFlowLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var items: Array<ComponentConf>;

	/**
		y spacing between each object
	**/
	public var ?spacing: Int;

	/**
		set flow.maxWidth
	**/
	public var ?maxWidth: Int;
}

/**
	attributes:

	spacing: Int - the spacing between each item
	align: String - "left"(default), "middle", "right"
**/
class VerticalFlowLayout extends Component {
	public function new() {
		super("layout-vflow");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final flow = make(zf.Access.xml(element), context);

		for (children in element.elements()) {
			final c = context.makeObjectFromXMLElement(children);
			if (c == null) continue;
			flow.addChild(c);
			// modify the position of the child
			final properties = flow.getProperties(c);

			final a = zf.Access.xml(children);
			var paddingTop = a.getInt("paddingTop");
			if (paddingTop != null) properties.paddingTop = paddingTop;
		}
		return flow;
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: VerticalFlowLayoutConf = c;
		final flow = make(zf.Access.struct(conf), context);

		for (item in conf.items) {
			final c = context.makeObjectFromStruct(item);
			if (c == null) continue;
			flow.addChild(c);
			if (item.layout != null) {
				final layout: LayoutConf = item.layout;
				if (layout.paddingTop != null) {
					final properties = flow.getProperties(c);
					properties.paddingTop = layout.paddingTop;
				}
			}
		}
		return flow;
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Flow {
		final flow = new h2d.Flow();
		flow.layout = Vertical;
		flow.horizontalAlign = switch (conf.getString("align")) {
			case "left": Left;
			case "right": Right;
			case "middle": Middle;
			default: Left;
		}

		final spacing = conf.getInt("spacing");
		if (spacing != null) flow.verticalSpacing = spacing;

		final maxWidth = conf.getInt("maxWidth");
		if (maxWidth != null) flow.maxWidth = maxWidth;
		return flow;
	}
}
