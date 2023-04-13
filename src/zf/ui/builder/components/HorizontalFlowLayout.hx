package zf.ui.builder.components;

typedef HorizontalFlowLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var ?items: Array<ComponentConf>;

	/**
		x spacing between each object
	**/
	public var ?spacing: Int;

	/**
		Max Horizontal width
	**/
	public var ?maxWidth: Int;
}

/**
	@stage:stable

	attributes:

	spacing: Int - the spacing between each item
	align: String - "top", "middle"(default), "bottom"
**/
class HorizontalFlowLayout extends Component {
	public function new() {
		super("layout-hflow");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final flow = make(zf.Access.xml(element), context);
		for (children in element.elements()) {
			final c = context.makeObjectFromXMLElement(children);
			if (c == null) continue;
			flow.addChild(c);
		}
		return flow;
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: HorizontalFlowLayoutConf = c;
		final flow = make(zf.Access.struct(c), context);
		if (conf.items != null) {
			for (item in conf.items) {
				final c = context.makeObjectFromStruct(item);
				if (c == null) continue;
				flow.addChild(c);
			}
		}
		return flow;
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Flow {
		final flow = new h2d.Flow();
		flow.layout = Horizontal;
		flow.verticalAlign = switch (conf.getString("align")) {
			case "top": Top;
			case "bottom": Bottom;
			case "middle": Middle;
			default: Middle;
		}
		final spacing = conf.getInt("spacing");
		if (spacing != null) flow.horizontalSpacing = spacing;
		final maxWidth = conf.getInt("maxWidth");
		if (maxWidth != null) {
			flow.maxWidth = maxWidth;
			flow.multiline = true;
			flow.verticalSpacing = spacing;
		}
		if (conf.get("name") != null) flow.name = conf.get("name");
		return flow;
	}
}
