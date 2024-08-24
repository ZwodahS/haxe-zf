package zf.ui;

import zf.h2d.Interactive;

typedef ScrollAreaConf = {
	public var object: h2d.Object;
	public var size: Point2i;

	/**
		Default to 0xffffffff
	**/
	public var ?cursorColor: Color;

	/**
		Cursor Factory for ScrollBar
	**/
	public var ?cursorFactory: zf.ui.ScaleGridFactory;
}

/**
	Wrap a object and make it scrollable
**/
class ScrollArea extends UIElement {
	public var displayObject: h2d.Object;
	public var size: Point2i;

	public var mask: h2d.Mask;
	public var scrollArea: h2d.Object;
	public var scrollbar: zf.ui.ScrollBar;

	public var cursorFactory: zf.ui.ScaleGridFactory;

	var padding: Point2i = [0, 0];

	public var scrollDirection: Int = 1;

	function new(object: h2d.Object) {
		super();
		this.displayObject = object;
	}

	function build() {
		this.addChild(this.interactive = new Interactive(this.size.x, this.size.y));

		this.mask = new h2d.Mask(this.size.x, this.size.y);
		mask.addChild(this.scrollArea = new h2d.Object());
		this.scrollArea.addChild(this.displayObject);
		this.addChild(mask);

		var bound = new h2d.col.Bounds();
		bound.xMin = 0;
		bound.yMin = 0;
		bound.xMax = this.size.x;
		bound.yMax = Math.max(this.size.y, scrollArea.getSize().height + 2);
		this.mask.scrollBounds = bound;

		this.scrollbar = new zf.ui.ScrollBar();
		this.scrollbar.cursorFactory = this.cursorFactory;
		this.scrollbar.scrollCursorWidth = 2;
		this.scrollbar.maxHeight = this.size.y - 10;
		this.scrollbar.attachTo(this.mask);
		this.addChild(this.scrollbar);
		this.scrollbar.x = this.size.x - 8;
		this.scrollbar.y = 5;

		this.addOnWheelListener("CardsView", (e) -> {
			scroll(e.wheelDelta * 30 * this.scrollDirection);
		});
	}

	public static function make(conf: ScrollAreaConf): ScrollArea {
		final scrollArea = new ScrollArea(conf.object);
		scrollArea.size = conf.size.clone();

		var cursorColor = 0xffffffff;
		if (conf.cursorColor != null) cursorColor = conf.cursorColor;

		if (conf.cursorFactory != null) {
			scrollArea.cursorFactory = conf.cursorFactory;
		} else {
			scrollArea.cursorFactory = new zf.ui.ScaleGridFactory(h2d.Tile.fromColor(cursorColor), 0, 0, 0, 0);
		}

		scrollArea.build();

		return scrollArea;
	}

	public function scroll(amount: Float) {
		this.mask.scrollY += amount;
	}

	/**
		Notify when the object is updated to update the mask bounds etc
	**/
	public function onObjectUpdated() {
		var bound = new h2d.col.Bounds();
		bound.xMin = 0;
		bound.yMin = 0;
		bound.xMax = size.x;
		bound.yMax = Math.max(size.y, scrollArea.getSize().height + 2);
		mask.scrollBounds = bound;
		this.scrollbar.onMaskUpdate();
		this.mask.scrollY = Math.clampF(this.mask.scrollY, 0, bound.yMax);
	}

	public function toBottom() {
		this.mask.scrollY = this.mask.scrollBounds.yMax;
	}
}
