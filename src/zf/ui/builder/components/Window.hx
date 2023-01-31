package zf.ui.builder.components;

/**
	@stage:stable

	A simple Window Component.

	Upon creation, set the default bgFactory and various configuration to use.

**/
class Window extends zf.ui.builder.Component {
	public var defaultBg: ScaleGridFactory;

	public var defaultPadding: Recti = [2, 2, 2, 2];

	public function new() {
		super("window");
		final t = h2d.Tile.fromColor(0xffffffff, 8, 8);
		this.defaultBg = new ScaleGridFactory(t, 2, 2);
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final access = zf.Access.xml(element);

		final item = element.firstElement();
		if (item == null) return null;

		final minWidth = access.getInt("minWidth", 450);
		final maxWidth = access.getInt("maxWidth", null);

		final object = context.makeObjectFromXMLElement(item);

		return wrap(object, this.defaultBg, this.defaultPadding, minWidth, maxWidth, null);
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final access = zf.Access.struct(c);

		var bgFactory: zf.ui.ScaleGridFactory = access.get("bgFactory");
		if (bgFactory == null) bgFactory = this.defaultBg;

		final item = context.makeObjectFromStruct(access.get("item"));
		if (item == null) return null;

		final minWidth = access.getInt("minWidth", 450);
		final maxWidth = access.getInt("maxWidth", null);

		return wrap(item, bgFactory, this.defaultPadding, minWidth, maxWidth, null);
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
