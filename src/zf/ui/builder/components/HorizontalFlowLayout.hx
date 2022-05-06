package zf.ui.builder.components;

typedef HorizontalFlowLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var items: Array<ComponentConf>;

	/**
		x spacing between each object
	**/
	public var ?spacing: Int;
}

/**
	attributes:

	spacing: Int - the spacing between each item
	align: String - "top", "middle"(default), "bottom"
**/
class HorizontalFlowLayout extends Component {
	public function new() {
		super("layout-hflow");
	}

	override public function makeFromXML(element: Xml): h2d.Object {
		final flow = make(zf.Access.xml(element));
		for (children in element.elements()) {
			final c = this.builder.makeObjectFromXMLElement(children);
			if (c == null) continue;
			flow.addChild(c);
		}
		return flow;
	}

	override public function makeFromStruct(c: Dynamic): h2d.Object {
		final conf: HorizontalFlowLayoutConf = c;
		final flow = make(zf.Access.struct(c));
		for (item in conf.items) {
			final c = this.builder.makeObjectFromStruct(item);
			flow.addChild(c);
		}
		return flow;
	}

	function make(conf: zf.Access): h2d.Flow {
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
		return flow;
	}
}
