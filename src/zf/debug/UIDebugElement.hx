package zf.debug;

import zf.ui.UIElement;
import zf.h2d.Interactive;

/**
	@stage:stable

	Use this only during development/debugging

	Fri 14:00:05 03 Mar 2023
	Rename MoveElement to a generic UIDebugElement
	Extends UIElement instead
**/
class UIDebugElement extends UIElement {
	public static var FontSize: Int = 6;

	var object: h2d.Object;
	var uiElement: UIElement;

	var infoObject: h2d.Object;
	var text: h2d.Text;
	var bg: h2d.Bitmap;
	var f: Int = 0;

	var moveInteractive: Interactive;

	public function new(object: h2d.Object, allowMove: Bool = true) {
		super();
		this.object = object;
		if (Std.isOfType(object, UIElement) == true) this.uiElement = cast object;

		makeInfoObject();

		if (allowMove == true) makeMove();

		this.object.addChild(this);
	}

	function makeMove() {
		@:privateAccess
		if (this.uiElement != null && this.uiElement.interactive != null) {
			this.uiElement.addOnPushListener("UIDebugElement.Move", onPush);
			this.uiElement.addOnClickListener("UIDebugElement.Move", onClick);
		} else {
			final size = this.object.getSize();
			this.moveInteractive = new Interactive(Std.int(size.width), Std.int(size.height), object);
			this.moveInteractive.enableRightButton = true;
			this.moveInteractive.onPush = onPush;
			this.moveInteractive.onClick = onClick;
		}
	}

	function makeInfoObject() {
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
			this.moveInteractive.startCapture(capture.bind(offsetX, offsetY));
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
