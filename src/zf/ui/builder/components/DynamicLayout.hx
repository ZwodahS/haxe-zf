package zf.ui.builder.components;

typedef DynamicLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var ?items: Array<ComponentConf>;
}

/**
	@stage:stable

	# Usage
	Create zf.ui.layout.DynamicLayout using xml

	<layout-dynamic>

	## Attributes
	- width|height: defined the width and height of the layout. Also set the width|height of the interactive.
	- interactive="true": create a interactive and set it to the layout.

	## Child Position/Attributes
	- position: define the position type, default "fixed"
		"anchorTopLeft"
		"anchorTopCenter"
		"anchorTopRight"
		"anchorCenter"
		"anchorBottomLeft"
		"anchorBottomRight"
		"fixed"
	- position-x|position-y: for "fixed" layout, set the position
	- position-spacingX|position-spacingY: for other layout, define the spacing.

	Note: All child object that is not UIElement will be wrapped around with a UIElement
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

		if (element.get("interactive") == "true") {
			final interactive = new zf.h2d.Interactive(width, height);
			layout.addChild(interactive);
			layout.interactive = interactive;
		}

		for (child in element.elements()) {
			var c = context.makeObjectFromXMLElement(child);
			if (c == null) continue;

			var uie: UIElement = null;
			// if it is not uielement, we wrap it around a uielement
			if (Std.isOfType(c, UIElement) == false) {
				uie = new UIElement();
				uie.addChild(c);
				@:privateAccess c.setParentContainer(uie);
			} else {
				uie = cast c;
			}

			var position: zf.ui.layout.DynamicLayout.DynamicPosition = Fixed(0, 0);
			switch (child.get("position")) {
				case "anchorTopLeft":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorTopLeft(spacingX, spacingY);
				case "anchorTopCenter":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorTopCenter(spacingX, spacingY);
				case "anchorTopRight":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorTopRight(spacingX, spacingY);
				case "anchorCenter":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorCenter(spacingX, spacingY);
				case "anchorBottomLeft":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorBottomLeft(spacingX, spacingY);
				case "anchorBottomRight":
					var spacingX = parseInt(child.get("position-spacingX"), 0);
					var spacingY = parseInt(child.get("position-spacingY"), 0);
					position = AnchorBottomRight(spacingX, spacingY);
				default: // "fixed"
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
