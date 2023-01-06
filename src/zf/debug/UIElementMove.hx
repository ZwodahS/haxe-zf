package zf.debug;

import zf.ui.UIElement;
import zf.h2d.Interactive;

/**
	@stage:stable

	Utility class to help me move ui element around to allow me to place them
	Use this only during development/debugging
**/
class UIElementMove extends h2d.Object {
	public static var FontSize: Int = 6;

	var object: h2d.Object;
	var uiElement: UIElement;
	var interactive: Interactive;

	var infoObject: h2d.Object;
	var text: h2d.Text;
	var bg: h2d.Bitmap;
	var f: Int = 0;

	public function new(object: h2d.Object) {
		super();
		this.object = object;
		final size = this.object.getSize();
		final isUIElement = Std.isOfType(object, UIElement);
		if (isUIElement == true) this.uiElement = cast object;
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

		@:privateAccess
		if (isUIElement == true && this.uiElement.interactive != null) {
			this.uiElement.addOnPushListener("D", onPush);
			this.uiElement.addOnClickListener("D", onClick);
		} else {
			this.interactive = new Interactive(Std.int(size.width), Std.int(size.height), object);
			this.interactive.enableRightButton = true;
			this.interactive.onPush = onPush;
			this.interactive.onClick = onClick;
		}

		this.object.addChild(this);
	}

	function onClick(e: hxd.Event) {
		if (e.button == 1) {
			final bound = this.object.getBounds(this.object.parent);
			final global = this.object.getBounds();
			var parentBound = null;
			if (this.object.parent.parent == null) { // parent is at the root level
				parentBound = this.object.parent.getBounds();
			} else {
				parentBound = this.object.parent.getBounds(this.object.parent.parent);
			}
			final bottomX = parentBound.xMax - bound.xMax;
			final bottomY = parentBound.yMax - bound.yMax;
			this.text.text = [
				'Object position      : [${object.x}, ${object.y}]',
				'Object Bound (parent): [${bound.xMin}, ${bound.yMin}, ${bound.xMax}, ${bound.yMax}]',
				'Object Bound (global): [${global.xMin}, ${global.yMin}, ${global.xMax}, ${global.yMax}]',
				'Object Bottom Anchor : [${bottomX}, ${bottomY}]',
			].join("\n");
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
		@:privateAccess
		if (this.uiElement != null && this.uiElement.interactive != null) {
			@:privateAccess var pos = this.uiElement.interactive.localToGlobal(new h2d.col.Point(offsetX, offsetY));
			pos = this.uiElement.globalToLocal(pos);
			offsetX = pos.x;
			offsetY = pos.y;

			@:privateAccess this.uiElement.interactive.startCapture(capture.bind(offsetX, offsetY));
		} else {
			this.interactive.startCapture(capture.bind(offsetX, offsetY));
		}
	}

	function capture(offsetX: Float, offsetY: Float, e: hxd.Event) {
		final scene = this.object.getScene();
		switch (e.kind) {
			case ERelease, EReleaseOutside:
				scene.stopCapture();
			case EPush:
			case EMove:
				final parent = object.parent;
				if (parent == null) {
					scene.stopCapture();
					return;
				}
				final positionX = scene.mouseX;
				final positionY = scene.mouseY;
				final pos = parent.globalToLocal(new h2d.col.Point(positionX, positionY));
				object.x = Std.int(pos.x - offsetX);
				object.y = Std.int(pos.y - offsetY);
			case EKeyDown:
			case EKeyUp:
			default:
		}
		e.propagate = false;
	}

	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		if (this.f == 0) return;
		this.f -= 1;
		if (this.f == 0) this.infoObject.remove();
	}
}
