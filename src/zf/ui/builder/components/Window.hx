package zf.ui.builder.components;

import zf.ui.WindowElement;

/**
	Wrap around an object with WindowElement
	WindowElement resize the background when the inner object is resized.

	# Attributes
	- minWidth=Int
	- maxWidth=Int
	- padding=Int
	- paddingTop=Int
	- paddingBottom=Int
	- paddingLeft=Int
	- paddingRight=Int
	- background=String -> bgFactories.get(background) ?? context.builder.getScaleGridFactory(background)
	- backgroundColor=String -> context.getColor
**/
class Window extends zf.ui.builder.Component {
	public var defaultBg: ScaleGridFactory;

	public var defaultPadding: Recti = [2, 2, 2, 2];

	public var bgFactories: Map<String, ScaleGridFactory>;

	public function new() {
		super("window");
		final t = h2d.Tile.fromColor(0xffffffff, 8, 8);
		this.defaultBg = new ScaleGridFactory(t, 2, 2);
		this.bgFactories = new Map<String, ScaleGridFactory>();
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final access = zf.Access.xml(element);

		final item = element.firstElement();
		if (item == null) return null;

		final minWidth = access.getInt("minWidth", null);
		final maxWidth = access.getInt("maxWidth", null);
		final minHeight = access.getInt("minHeight", null);

		// handle padding parsing
		var paddings: Recti = this.defaultPadding.clone();
		final padding = access.getInt("padding", null);
		if (padding != null) {
			paddings.xMin = padding;
			paddings.xMax = padding;
			paddings.yMin = padding;
			paddings.yMax = padding;
		} else {
			final paddingTop = access.getInt("paddingTop", null);
			var paddingBottom = access.getInt("paddingBottom", null);
			if (paddingTop != null && paddingBottom == null) paddingBottom = paddingTop;
			final paddingLeft = access.getInt("paddingLeft", null);
			var paddingRight = access.getInt("paddingRight", null);

			if (paddingLeft != null && paddingRight == null) paddingRight = paddingLeft;
			if (paddingTop != null) paddings.yMin = paddingTop;
			if (paddingBottom != null) paddings.yMax = paddingBottom;
			if (paddingLeft != null) paddings.xMin = paddingLeft;
			if (paddingRight != null) paddings.xMax = paddingRight;
		}

		final bgId = access.getString("background");
		var bgFactory = this.bgFactories.get(bgId) ?? context.builder.getScaleGridFactory(bgId) ?? this.defaultBg;

		final createInteractive = access.getBool("interactive");

		final object = context.makeObjectFromXMLElement(item);

		final window: WindowElement = cast wrap(object, bgFactory, paddings, minWidth, maxWidth, minHeight);

		final colorId = access.getString("backgroundColor");
		if (colorId != null) {
			final color = context.getColor(colorId);
			window.background.color = h3d.Vector4.fromColor(color);
		}

		if (createInteractive == true) {
			window.resizeInteractive = true;
			window.interactive = new zf.h2d.Interactive(10, 10);
			window.addChild(window.interactive);
		}
		window.resizeBackground();

		return window;
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final access = zf.Access.struct(c);

		var bgFactory: zf.ui.ScaleGridFactory = access.get("bgFactory");
		if (bgFactory == null) bgFactory = this.defaultBg;

		final item = context.makeObjectFromStruct(access.get("item"));
		if (item == null) return null;

		final minWidth = access.getInt("minWidth", null);
		final maxWidth = access.getInt("maxWidth", null);
		final minHeight = access.getInt("minHeight", null);
		final paddings = access.getArray("paddings", defaultPadding);

		return wrap(item, bgFactory, paddings, minWidth, maxWidth, minHeight);
	}

	// @formatter:off
	public static function wrap(object: h2d.Object,
			bgFactory: ScaleGridFactory, padding: Recti = null,
			minWidth: Null<Int> = null, maxWidth: Null<Int> = null, minHeight: Null<Int> = null): h2d.Object {
		final window = new WindowElement(bgFactory.make(10, 10), object);
		window.minWidth = minWidth;
		window.maxWidth = maxWidth;
		window.minHeight = minHeight;
		window.paddingLeft = padding.left;
		window.paddingRight = padding.right;
		window.paddingTop = padding.top;
		window.paddingBottom = padding.bottom;
		@:privateAccess window.render();
		return window;
	}

}

/**
	Thu 16:36:41 12 Jun 2025
	Allow getting of background scalegrid from builder
**/
