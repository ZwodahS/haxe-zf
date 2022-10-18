package zf.debug;

import zf.h2d.Interactive;

/**
	Utility class to help me move ui element around to allow me to place them

	Use this only during development

	Fri 14:43:16 14 Oct 2022
	WIP, will upgrade this later on
**/
class UIElementMove extends h2d.Object {
	public var object: h2d.Object;

	public var interactive: Interactive;
	public var infoObject: h2d.Object;
	public var text: h2d.Text;
	public var bg: h2d.Bitmap;
	public var f: Int = 0;

	public function new(object: h2d.Object) {
		super();
		this.object = object;
		final size = this.object.getSize();
		this.interactive = new Interactive(Std.int(size.width), Std.int(size.height), object);
		final font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(6);
		this.text = new h2d.Text(font);
		this.infoObject = new h2d.Object();
		this.bg = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, 1, 1));
		this.bg.alpha = .7;
		this.text.x = 2;
		this.text.y = 2;
		this.infoObject.addChild(bg);
		this.infoObject.addChild(this.text);

		this.interactive.onPush = (e) -> {
			final scene = this.object.getScene();
			this.interactive.startCapture(function(e) {
				switch (e.kind) {
					case ERelease, EReleaseOutside:
						scene.stopCapture();
						final bound = this.object.getBounds();
						final parentBound = this.object.parent.getBounds();
						this.text.text = [
							'[${bound.xMin}, ${bound.yMin}, ${bound.xMax}, ${bound.yMax}]',
							'[${parentBound.xMax - bound.xMax}, ${parentBound.yMax - bound.yMax}]',
						].join("\n");
						this.text.textColor = 0xffffffff;
						final scene = this.getScene();
						if (scene != null) {
							scene.addChild(this.infoObject);
							infoObject.x = scene.mouseX;
							infoObject.y = scene.mouseY;
							final size = this.text.getSize();
							this.bg.width = size.width + 4;
							this.bg.height = size.height + 4;
						}
						this.f = 300;
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
						object.x = pos.x - this.interactive.width / 2;
						object.y = pos.y - this.interactive.height / 2;
					case EKeyDown:
					case EKeyUp:
					default:
				}
				e.propagate = false;
			});
		}
		this.object.addChild(this);
	}

	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		if (this.f == 0) return;
		this.f -= 1;
		if (this.f == 0) this.infoObject.remove();
	}
}

class D {
	public static function makeMovable(object: h2d.Object): UIElementMove {
#if !debug
		Logger.warn("D is used outside of debug mode");
		return null;
#else
		return new UIElementMove(object);
#end
	}
}
