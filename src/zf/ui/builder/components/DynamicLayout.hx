package zf.ui.builder.components;

typedef DynamicLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var ?items: Array<ComponentConf>;
}

/**
	@stage:stable
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
		inline function parseInt(v: Dynamic, defaultValue: Null<Int> = null): Null<Int> {
			if (v == null) return defaultValue;
			return Std.parseInt(v);
		}

		final width = parseInt(element.get("width"), 0);
		final height = parseInt(element.get("height"), 0);
		final layout = new zf.ui.layout.DynamicLayout([width, height]);
		for (child in element.elements()) {
			var c = context.makeObjectFromXMLElement(child);
			if (c == null) continue;

			var uie: UIElement = null;
			// if it is not uielement, we wrap it around a uielement
			if (Std.isOfType(c, UIElement) == false) {
				uie = new UIElement();
				uie.addChild(c);
			} else {
				uie = cast c;
			}

			var position: zf.ui.layout.DynamicLayout.DynamicPosition = Fixed(0, 0);
			switch (child.get("position")) {
				case "anchorTopLeft":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorTopLeft(spacingX, spacingY);
				case "anchorTopRight":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorTopRight(spacingX, spacingY);
				case "anchorBottomLeft":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorBottomLeft(spacingX, spacingY);
				case "anchorBottomRight":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorBottomRight(spacingX, spacingY);
				default:
					"fixed";
					var x = parseInt(child.get("position-x"), 0);
					var y = parseInt(child.get("position-y"), 0);
					position = Fixed(x, y);
			}
			uie.position = position;
			layout.addChild(uie);
		}
		return layout;
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: DynamicLayoutConf = c;
		final obj = new h2d.Object();
		if (conf.items != null) {
			for (item in conf.items) {
				final c = context.makeObjectFromStruct(item);
				if (c == null) continue;
				final compConf: DynamicAccess<Dynamic> = item.conf;
				if (compConf.get("x") != null) c.x = compConf.get("x");
				if (compConf.get("y") != null) c.y = compConf.get("y");
				obj.addChild(c);
			}
		}
		return obj;
	}
}
