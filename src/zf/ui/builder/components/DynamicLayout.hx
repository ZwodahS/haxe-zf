package zf.ui.builder.components;

typedef DynamicLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var ?items: Array<ComponentConf>;
}

/**
	Create zf.ui.layout.DynamicLayout using xml

	## Attributes
	- width (default null)
	- height (default null)
	- interactive="true": create a interactive and set it to the layout.

	## Child Position/Attributes
	- position: define the position type, default "absolute"
	- position-x|position-y:
	- position-spacingX|position-spacingY is also supported.
**/
class DynamicLayout extends Component {
	public function new() {
		super("layout-dynamic");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		/**
			For object, we assume that each object will be added in order
			and the position of each of the item will be set based on the attribute
		**/
		function parseInt(v: Dynamic, defaultValue: Null<Int> = null): Null<Int> {
			if (v == null) return defaultValue;

			final parsed = Std.parseInt(v);
			if (parsed != null) return parsed;

			final i = context.get(cast v);
			if (i is Int) return cast i;
			return defaultValue;
		}

		final width = parseInt(element.get("width"), null);
		final height = parseInt(element.get("height"), null);
		final layout = zf.ui.layout.DynamicLayout.alloc(width, height);

		final interactiveConf = element.get("interactive");
		var interactive: zf.h2d.Interactive = null;
		if (interactiveConf == "true" || interactiveConf == "resize") {
			interactive = new zf.h2d.Interactive(width, height);
			layout.addChild(interactive);
			layout.interactive = interactive;
		}

		for (child in element.elements()) {
			final c = context.makeObjectFromXMLElement(child);
			if (c == null) continue;

			layout.addChild(c);
			final prop = layout.getProperties(c);
			final conf = zf.Access.xml(child);

			final x = parseInt(child.get("position-x") ?? child.get("position-spacingX"), 0);
			final y = parseInt(child.get("position-y") ?? child.get("position-spacingY"), 0);

			// We will prevent the propagation while we setting the properties
			@:privateAccess prop.layout = null;

			prop.position = switch ((child.get("position") ?? "absolute").toLowerCase()) {
				case "absolute": Absolute(x, y);
				case "anchortopleft": AnchorTopLeft(x, y);
				case "anchortopcenter": AnchorTopCenter(x, y);
				case "anchortopright": AnchorTopRight(x, y);
				case "anchorcenterleft": AnchorCenterLeft(x, y);
				case "anchorcentercenter": AnchorCenterCenter(x, y);
				case "anchorcenterright": AnchorCenterRight(x, y);
				case "anchorbottomleft": AnchorBottomLeft(x, y);
				case "anchorbottomcenter": AnchorBottomCenter(x, y);
				case "anchorbottomright": AnchorBottomRight(x, y);
				default: Absolute(x, y);
			}

			@:privateAccess prop.layout = layout;
		}

		if (interactiveConf == "resize") {
			final size = layout.getSize();
			interactive.width = size.width;
			interactive.height = size.height;
		}

		@:privateAccess layout.repositionAll = true;

		return layout;
	}
}
