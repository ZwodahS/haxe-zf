package zf.debug;

using zf.h2d.ObjectExtensions;

import zf.ui.UIElement;
import zf.h2d.Interactive;

class UIElementResize extends h2d.Object {
	public static var FontSize: Int = 6;

	var object: h2d.Object;
	var interactive: Interactive;

	var infoObject: h2d.Object;
	var text: h2d.Text;
	var bg: h2d.Bitmap;
	var f: Int = 0;

	var width: Float = 0;
	var height: Float = 0;

	public function new(object: h2d.Object) {
		super();
		this.object = object;

		this.interactive = new Interactive(5, 5, object);

		this.interactive.enableRightButton = true;
		this.interactive.onPush = onPush;
		this.interactive.onClick = onClick;
		// @todo make a custom resize cursor ?
		this.interactive.cursor = Move;
		calcSize();
		alignInteractive();

		final font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(FontSize);
		this.text = new h2d.Text(font);
		this.infoObject = new h2d.Object();
		this.bg = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, 1, 1));
		this.bg.alpha = .7;
		this.text.x = 2;
		this.text.y = 2;
		this.infoObject.addChild(bg);
		this.infoObject.addChild(this.text);
	}

	function alignInteractive() {
		this.interactive.setX(this.width - 5).setY(this.height - 5);
	}

	function calcSize() {
		if (Std.isOfType(this.object, zf.h2d.ScaleGrid)) {
			final scaleGrid: zf.h2d.ScaleGrid = cast this.object;
			this.width = scaleGrid.width;
			this.height = scaleGrid.height;
		}
	}

	function onClick(e: hxd.Event) {
		if (e.button == 1) {
			final size = getObjectSize();
			this.text.text = ['Object size: ${size.x}, ${size.y}',].join("\n");
			trace(this.text.text);
			this.text.textColor = 0xffffffff;
			final scene = this.getScene();
			if (scene != null) {
				scene.addChild(this.infoObject);
				infoObject.x = scene.mouseX;
				infoObject.y = scene.mouseY;
				final size = this.text.getSize();
				this.bg.width = size.width + 4;
				this.bg.height = size.height + 4;
				this.f = 300;
			}
		}
	}

	function onPush(e: hxd.Event) {
		if (e.button == 1) return;
		final scene = this.object.getScene();
		var offsetX = e.relX;
		var offsetY = e.relY;
		this.interactive.startCapture(capture.bind(offsetX, offsetY));
	}

	function capture(offsetX: Float, offsetY: Float, e: hxd.Event) {
		final scene = this.object.getScene();
		switch (e.kind) {
			case ERelease, EReleaseOutside:
				scene.stopCapture();
				calcSize();
				alignInteractive();
			case EPush:
			case EMove:
				resize(e.relX, e.relY);
			case EKeyDown:
			case EKeyUp:
			default:
		}
		e.propagate = false;
	}

	function resize(x: Float, y: Float) {
		if (Std.isOfType(this.object, zf.h2d.ScaleGrid)) {
			final scaleGrid: zf.h2d.ScaleGrid = cast this.object;
			scaleGrid.width = this.width + x;
			scaleGrid.height = this.height + y;
		} else {}
	}

	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		if (this.f == 0) return;
		this.f -= 1;
		if (this.f == 0) this.infoObject.remove();
	}

	function getObjectSize(): Point2f {
		if (false) {
			return [0, 0];
		} else {
			final size = this.object.getSize();
			return [size.width, size.height];
		}
	}
}
