package zf.ui;

import zf.h2d.Interactive;
import zf.h2d.ScaleGrid;
import zf.ui.ScaleGridFactory;

/**
	@:stage:stable
**/
class ScrollBar extends h2d.Object {
	public var cursorFactory: ScaleGridFactory = null;

	var displayMask: h2d.Mask;

	/**
		maximum height of the scrollbar
	**/
	public var maxHeight: Float = 0;

	public var scrollBarWidth: Float = 10;
	public var scrollCursorWidth: Float = 6;

	var interactive: Interactive;
	var scrollCursor: ScaleGrid; // the bar that is rendered

	public var scrollY(get, set): Float;
	public var scrollPercentage(get, set): Float;

	public function new() {
		super();
		this.cursorFactory = new ScaleGridFactory(h2d.Tile.fromColor(-1), 0, 0, 0, 0);
	}

	public function attachTo(mask: h2d.Mask) {
		if (this.displayMask != null) detachMask();
		this.displayMask = mask;
		// create the various component

		this.scrollCursor = this.cursorFactory.make([Std.int(scrollCursorWidth), 100]);
		this.scrollCursor.x = (this.scrollBarWidth - this.scrollCursorWidth) / 2;
		this.addChild(scrollCursor);

		this.interactive = new Interactive(scrollBarWidth, maxHeight);
		this.interactive.onPush = function(e: hxd.Event) {
			final scene = getScene();
			if (scene == null) return;
			this.interactive.startCapture(function(e) {
				switch (e.kind) {
					case ERelease, EReleaseOutside:
						scene.stopCapture();
					case EPush, EMove:
						updateCursor(e);
					default:
				}
				e.propagate = false;
			});
			updateCursor(e);
		};
		this.addChild(interactive);
		onMaskUpdate();
	}

	public function detachMask() {
		if (this.interactive != null) this.interactive.remove();
		if (this.scrollCursor != null) this.scrollCursor.remove();
	}

	function updateCursor(e: hxd.Event) {
		final cursorTop = e.relY - this.scrollCursor.height * 0.5;
		this.scrollPercentage = cursorTopToScrollPercentage(cursorTop);
	}

	function cursorTopToScrollPercentage(y: Float): Float {
		// the movable height of the cursor is this.maxHeight - this.scrollCursor.height
		final maxScrollableHeight = this.maxHeight - this.scrollCursor.height;
		if (y < 0) return 0;
		if (y >= maxScrollableHeight) return 1.0;
		return (y / maxScrollableHeight);
	}

	function scrollPercentageToCursorTop(p: Float): Float {
		// the movable height of the cursor is this.maxHeight - this.scrollCursor.height
		final maxScrollableHeight = this.maxHeight - this.scrollCursor.height;
		if (p < 0) return 0;
		if (p >= 1.0) return maxScrollableHeight;
		return p * maxScrollableHeight;
	}

	public function get_scrollY(): Float {
		return this.displayMask == null ? 0 : this.displayMask.scrollY;
	}

	public function set_scrollY(y: Float): Float {
		if (this.displayMask == null) return 0;
		this.displayMask.scrollY = y;
		return this.displayMask.scrollY;
	}

	public function set_scrollPercentage(p: Float): Float {
		if (p < 0) p = 0;
		if (p > 1) p = 1;

		if (this.displayMask == null) return p;

		this.scrollY = (this.displayMask.scrollBounds.yMax - this.displayMask.height) * p;

		return p;
	}

	public function get_scrollPercentage(): Float {
		if (this.displayMask == null) return 0;
		return this.scrollY / (this.displayMask.scrollBounds.yMax - this.displayMask.height);
	}

	function onScrollUpdated() {
		if (this.displayMask == null) return;
		final cursorTop = scrollPercentageToCursorTop(this.scrollPercentage);
		this.scrollCursor.y = cursorTop;
	}

	public function onMaskUpdate() {
		// sometimes the mask is updated, so we need to call this to update the size of scroll etc
		var renderHeight = this.maxHeight - ((this.displayMask.scrollBounds.yMax - this.displayMask.height) * 1);
		// currently hardcoded that if the rendered height is < 10% of the max height, we will render at 10% height
		if (renderHeight < this.maxHeight * .1) renderHeight = .1 * this.maxHeight;
		this.scrollCursor.height = renderHeight;
	}

	override public function sync(ctx: h2d.RenderContext) {
		// because the mask's scroll may be changed outside of the scroll bar, we want to
		// update the cursor position on every frame.
		this.onScrollUpdated();
		super.sync(ctx);
	}
}
