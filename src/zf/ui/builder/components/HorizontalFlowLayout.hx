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
	Create a h2d.Flow with layout = horizontal

	# Attributes (Flow)
	These are mapped to various attribute in h2d.Flow

	- align=["top"|"bottom"|"middle"] -> flow.verticalAlign
	- spacing=Int -> flow.horizontalSpacing
	- maxWidth=Int -> flow.maxWidth, will also set flow.multiline to true
		- spacingY -> if maxWidth is set, spacingY is available to set flow.verticalSpacing
			if not provided, spacing will be used.
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
		final childrenKey: String = conf.getString("children");
		final loopData: Array<Dynamic> = if (loopKey == null) null else context.data.get(loopKey);
		final children: Array<Dynamic> = if (childrenKey == null) null else context.data.get(childrenKey);
		if (loopData != null) {
			for (data in loopData) {
				final ctx = context.expandTemplateContext(data);
				for (e in element.elements()) addElement(e, ctx);
			}
		} else if (children != null) {
			// if children key is not null, we will assume that each element inside is a h2d.Object
			for (c in children) {
				if (c is h2d.Object) flow.addChild(cast(c, h2d.Object));
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
			final spacingY = conf.getInt("spacingY");
			if (spacingY != null) {
				flow.verticalSpacing = spacingY;
			} else if (spacing != null) {
				flow.verticalSpacing = spacing;
			}
		}

		if (conf.get("name") != null) {
			Logger.debug("[Deprecated] name is deprecated for component, use id instead");
			flow.name = conf.get("name");
		}
		return flow;
	}
}

/**
	Sun 11:38:21 15 Jun 2025
	Features are implemented on a need basis
**/
