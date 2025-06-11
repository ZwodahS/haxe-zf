package zf.ui.builder.components;

private typedef LayoutConf = {
	public var ?paddingTop: Int;
}

typedef VerticalFlowLayoutConf = {
	/**
		All item in this flow layout
	**/
	public var ?items: Array<ComponentConf>;

	/**
		y spacing between each object
	**/
	public var ?spacing: Int;

	/**
		set flow.maxWidth
	**/
	public var ?maxWidth: Int;

	/**
		Take items from builder context instead.
	**/
	public var ?itemsKey: String;
}

/**
	Create a h2d.Flow with layout = vertical

	# Attributes (Flow)
	These are mapped to various attributes in h2d.Flow

	- align=["left"(default),"middle","right"] -> flow.horizontalAlign
	- spacing=Int -> flow.verticalSpacing
	- maxWidth=Int -> flow.maxWidth

	These are non-mapped keys
	- itemsKey=String
		If this is provided, then the items will be taken from BuilderContext.
		Each item should be a h2d.Object
	- loopData=String
		if provided, each children will be looped against each item in loopData,
		i.e. the number of actual children in flow will be children.length X loopData.length
		loopData is a String and the actual data is taken from Context.

	# Attributes (Children)
	- flowAlign=["center","left","right"] - override flow.Properties.horizontalAlign
**/
class VerticalFlowLayout extends Component {
	public function new() {
		super("layout-vflow");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);
		final flow = make(conf, context);

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final c = newContext.makeObjectFromXMLElement(e);
			if (c == null) return null;

			flow.addChild(c);
			// modify the position of the child
			final conf = zf.Access.xml(e);

			final overrideAlign = e.get("flowAlign");
			if (overrideAlign != null) {
				final prop = flow.getProperties(c);
				prop.horizontalAlign = switch (overrideAlign) {
					case "center": Middle;
					case "left": Left;
					case "right": Right;
					default: null;
				}
			}

			return c;
		}

		final loopKey: String = conf.getString("loopData");
		final loopData: Array<Dynamic> = if (loopKey == null) null else context.data.get(loopKey);
		if (loopData != null) {
			for (data in loopData) {
				final ctx = context.expandTemplateContext(data);
				for (e in element.elements()) addElement(e, ctx);
			}
		} else {
			for (e in element.elements()) addElement(e, context);
		}
		return flow;
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: VerticalFlowLayoutConf = c;
		final flow = make(zf.Access.struct(conf), context);

		if (conf.items != null) {
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

		final itemsKey = conf.get("itemsKey");
		if (itemsKey != null && context.data.exists(itemsKey)) {
			try {
				final arr: Array<Dynamic> = cast context.data.get(itemsKey);
				for (item in arr) {
					final obj: h2d.Object = cast item;
					if (obj != null) flow.addChild(item);
				}
			} catch (e) {
				Logger.exception(e);
			}
		}

		final spacing = conf.getInt("spacing");
		if (spacing != null) flow.verticalSpacing = spacing;

		final maxWidth = conf.getInt("maxWidth");
		if (maxWidth != null) flow.maxWidth = maxWidth;
		if (conf.get("name") != null) {
			Logger.debug("[Deprecated] name is deprecated for component, use id instead");
			flow.name = conf.get("name");
		}
		return flow;
	}
}

/**
	Fri 14:19:44 13 Jun 2025
	Features are implemented on a need basis
**/
