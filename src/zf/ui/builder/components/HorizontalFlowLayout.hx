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
		final conf = zf.Access.xml(element);
		final flow = make(conf, context);

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final c = newContext.makeObjectFromXMLElement(e);
			if (c == null) return;
			flow.addChild(c);
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
		if (spacing != null) flow.horizontalSpacing = spacing;

		final maxWidth = conf.getInt("maxWidth");
		if (maxWidth != null) {
			flow.maxWidth = maxWidth;
			flow.multiline = true;
			flow.verticalSpacing = spacing;
		}

		if (conf.get("name") != null) {
			Logger.debug("[Deprecated] name is deprecated for component, use id instead");
			flow.name = conf.get("name");
		}
		return flow;
	}
}
