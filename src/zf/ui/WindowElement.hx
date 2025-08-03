package zf.ui;

/**
	UIElement that contains a background + a inner object.

	@see zf.ui.components.Window
**/
class WindowElement extends zf.h2d.Container {
	public var background: zf.h2d.ScaleGrid;
	public var object: h2d.Object;

	public var maxWidth: Null<Int> = null;
	public var minWidth: Null<Int> = null;
	public var minHeight: Null<Int> = null;

	public var paddingLeft: Int = 0;
	public var paddingRight: Int = 0;
	public var paddingTop: Int = 0;
	public var paddingBottom: Int = 0;

	public var resizeInteractive: Bool = false;

	var resize: Bool = false;

	public function new(background: zf.h2d.ScaleGrid, object: h2d.Object) {
		super();
		this.background = background;
		this.object = object;
	}

	function render() {
		this.addChild(this.background);
		this.addChild(this.object);

		resizeBackground();

		this.object.x = paddingLeft;
		this.object.y = paddingTop;
	}

	override public function contentChanged(object: h2d.Object) {
		this.resize = true;
		onContentChanged();
	}

	override function sync(ctx: h2d.RenderContext) {
		if (this.resize == true) {
			resizeBackground();
			this.resize = false;
		}
		super.sync(ctx);
	}

	public function resizeBackground() {
		final bounds = this.object.getBounds();
		this.background.width = Math.clampI(Std.int(bounds.width) + paddingLeft + paddingRight, minWidth, maxWidth);
		this.background.height = Math.clampI(Std.int(bounds.height) + paddingTop + paddingBottom, minHeight, null);

		if (this.resizeInteractive == true && this.interactive != null) {
			this.interactive.width = this.background.width;
			this.interactive.height = this.background.height;
		}
	}
}

/**
	Thu 17:06:58 12 Jun 2025
	Previously in zf.ui.components.Window, this was handled as UIElement.

	However, I need a way to resize the background when the element inside changes.

	Extend when necessary
**/
