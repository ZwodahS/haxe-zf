package zf.debug;

import zf.ui.UIElement;
import zf.h2d.HtmlText;
import zf.ui.ScrollArea;
import zf.h2d.Interactive;

using zf.StringExtensions;

import hxd.Key;

class OverlayInspector extends h2d.Object {
	var game: Game;

	public var tree: ObjectViewer;

	public var conf = {
		alpha: 0.9,
		bgColor: 0xff111012,
		width: 0, // set by DebugOverlay
		height: 0, // set by DebugOverlay
		textColor: 0xfffffbe5,
	}

	public var font: h2d.Font;

	var scrollArea: ScrollArea;

	public function new(font: h2d.Font, game: Game) {
		super();
		this.game = game;
		this.font = font;
	}

	public function init() {
		final bg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		bg.width = this.conf.width;
		bg.height = this.conf.height;
		bg.alpha = this.conf.alpha;
		this.addChild(bg);

		this.tree = new ObjectViewer(this.font);
		this.tree.conf.width = this.conf.width - 4;
		this.tree.conf.height = this.conf.height - 4;
		this.tree.init();
		this.tree.x = 2;
		this.tree.y = 2;
		this.addChild(this.tree);
	}

	public function refresh() {
		final objects = getManagedObjects();
		inspectObjects(objects);
	}

	dynamic public function getManagedObjects(): Array<{name: String, object: Dynamic}> {
		return [];
	}

	function inspectObjects(objects: Array<{name: String, object: Dynamic}>) {
		this.tree.clear();
		for (o in objects) {
			this.tree.addNode(o.object, o.name);
		}
	}

	public function onShow() {
		this.refresh();
	}

	dynamic public function hide() {}
}
