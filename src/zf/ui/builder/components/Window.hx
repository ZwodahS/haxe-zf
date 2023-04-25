package zf.ui.builder.components;

/**
	@stage:stable

	A simple Window Component.

	Upon creation, set the default bgFactory and various configuration to use.

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

		final minWidth = access.getInt("minWidth", 450);
		final maxWidth = access.getInt("maxWidth", null);

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
		var bgFactory = this.defaultBg;
		if (bgId != null && this.bgFactories.exists(bgId)) {
			bgFactory = this.bgFactories[bgId];
		}

		final object = context.makeObjectFromXMLElement(item);

		return wrap(object, bgFactory, paddings, minWidth, maxWidth, null);
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final access = zf.Access.struct(c);

		var bgFactory: zf.ui.ScaleGridFactory = access.get("bgFactory");
		if (bgFactory == null) bgFactory = this.defaultBg;

		final item = context.makeObjectFromStruct(access.get("item"));
		if (item == null) return null;

		final minWidth = access.getInt("minWidth", 450);
		final maxWidth = access.getInt("maxWidth", null);
		final paddings = access.getArray("paddings", defaultPadding);

		return wrap(item, bgFactory, paddings, minWidth, maxWidth, null);
	}

	// @formatter:off
	public static function wrap(object: h2d.Object,
			bgFactory: ScaleGridFactory, padding: Recti = null,
			minWidth: Null<Int> = null, maxWidth: Null<Int> = null, minHeight: Null<Int> = null): h2d.Object {
		if (padding == null) padding = [0, 0, 0, 0];
		final bounds = object.getBounds();
		final windowSize = getWindowSize(bounds, padding, minWidth, maxWidth, minHeight);
		final obj = new h2d.Object();
		obj.addChild(bgFactory.make(windowSize));
		obj.addChild(object);
		object.x = padding.xMin;
		object.y = padding.yMin;
		return obj;
	}

	static function getWindowSize(bounds: h2d.col.Bounds, padding: Recti, minWidth: Null<Int> = null,
			maxWidth: Null<Int> = null, minHeight: Null<Int> = null): Point2i {
		final windowSize: Point2i = [Std.int(bounds.width), Std.int(bounds.height)];
		windowSize.x += padding.xMin + padding.xMax;
		windowSize.y += padding.yMin + padding.yMax;
		windowSize.x = Math.clampI(windowSize.x, minWidth, maxWidth);
		windowSize.y = Math.clampI(windowSize.y, minHeight, null);
		return windowSize;
	}
}
