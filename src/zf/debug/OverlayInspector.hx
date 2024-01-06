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
		paddingX: 2,
		bgColor: 0xff111012,
		inputHeight: 0,
		width: 0, // set by DebugOverlay
		height: 0, // set by DebugOverlay
		textColor: 0xfffffbe5,
	}

	public var font: h2d.Font;

	var scrollArea: ScrollArea;

	var input: h2d.TextInput;
	var inputBg: h2d.Bitmap;

	public function new(font: h2d.Font, game: Game) {
		super();
		this.game = game;
		this.font = font;
	}

	public function init() {
		final bg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		bg.width = this.conf.width;
		bg.height = this.conf.height - this.conf.inputHeight - 4;
		bg.alpha = this.conf.alpha;
		this.addChild(bg);

		this.tree = new ObjectViewer(this.font);
		this.tree.conf.width = this.conf.width - 4;
		this.tree.conf.height = this.conf.height - 24;
		this.tree.init();
		this.tree.x = 2;
		this.tree.y = 2;
		this.tree.onKeyDown = (e) -> {
			this.input.focus();
		}
		this.addChild(this.tree);

		this.inputBg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		this.inputBg.width = this.conf.width;
		this.inputBg.height = this.conf.inputHeight;
		final inputInteractive = new zf.h2d.Interactive(this.conf.width, this.conf.height);
		this.inputBg.addChild(inputInteractive);
		inputInteractive.onClick = (_) -> {
			this.input.focus();
		}
		this.input = new h2d.TextInput(this.font);
		this.input.textColor = this.conf.textColor;
		this.input.text = '';
		this.input.onKeyDown = handleKey;
		this.input.onChange = handleCmdChange;
		this.inputBg.x = 0;
		this.inputBg.y = this.conf.height - this.conf.inputHeight;
		this.input.x = this.conf.paddingX;
		this.input.y = this.conf.height - this.conf.inputHeight;
		this.addChild(this.inputBg);
		this.addChild(this.input);
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
		this.input.focus();
	}

	dynamic public function hide() {}

	function handleKey(e: hxd.Event) {
		if (this.visible == false) return;
		switch (e.keyCode) {
			case Key.ENTER, Key.NUMPAD_ENTER:
				final cmd = this.input.text;
				expandNode(cmd);
				e.cancel = true;
				return;

			case Key.W:
				if (Key.isDown(Key.CTRL) == true) removeWord();

			case Key.ESCAPE:
				hide();
		}
	}

	function handleCmdChange() {}

	function expandNode(cmd: String) {
		this.tree.expandPath(cmd);
	}

	public function removeWord() {
		if (this.input.text.charAt(this.input.text.length - 1) == ".") {
			this.input.text = this.input.text.substring(0, this.input.text.length - 1);
			return;
		}
		var index = this.input.text.lastIndexOf(".");
		if (index == -1) index = 0;
		this.input.text = this.input.text.substr(0, index + (index == 0 ? 0 : 1));
		handleCmdChange();
	}
}
