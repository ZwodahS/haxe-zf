package zf.debug;

import zf.ui.UIElement;
import zf.h2d.HtmlText;
import zf.h2d.Interactive;
import zf.ui.Button;

import hxd.Key;

/**
	Motivation:

	Console is good, but I needed something better.
	The goal of this is to combine Console and other tools that I might need.

	- F1 (Console)
	- F2 (Variable Inspector)
**/
class DebugOverlay extends UIElement {
	public var game: Game;

	public var console: OverlayConsole;
	public var inspector: OverlayInspector;

	public var conf = {
		alpha: 0.8,
		padding: 5, // the padding around the console area
		spacing: 5,
		button: {
			size: [50, 12],
			bgColor: [0xff111012, 0xff8c7f5a, 0xfffff703, 0xff3f7082],
			textColor: 0xfffffbe5,
		},
		console: {
			inputHeight: 10,
		},
	};

	public var fonts: Array<h2d.Font>;

	var displayAreaWidth(get, never): Int;

	function get_displayAreaWidth(): Int {
		return this.game.gameWidth - (this.conf.padding * 2);
	}

	var displayAreaHeight(get, never): Int;

	function get_displayAreaHeight(): Int {
		return this.game.gameHeight - (this.conf.padding * 2) - this.conf.spacing - this.conf.button.size[1];
	}

	var displayAreaStartY(get, never): Int;

	function get_displayAreaStartY(): Int {
		return this.conf.padding + this.conf.spacing + this.conf.button.size[1];
	}

	public function new(game: Game) {
		super();
		this.game = game;

		this.fonts = [];
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(6);
		this.fonts.push(font);
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(8);
		this.fonts.push(font);
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(10);
		this.fonts.push(font);
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(12);
		this.fonts.push(font);
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(14);
		this.fonts.push(font);
	}

	public function init() {
		this.addChild(this.interactive = new Interactive(this.game.gameWidth, this.game.gameHeight));
		this.addOnKeyDownListener("DebugOverlay", (e) -> {
			if (this.visible == false) return;
			if (e.keyCode == Key.ESCAPE) hide();
		});
		this.interactive.propagateEvents = false;
		initButtons();
		initConsole();
		initInspector();
		this.visible = false;

		selectConsole();
	}

	var consoleBtn: Button;
	var inspectorBtn: Button;

	function initButtons() {
		// init buttons

		function makeButton(text: String): Button {
			final btn = Button.fromColor({
				defaultColor: this.conf.button.bgColor[0],
				hoverColor: this.conf.button.bgColor[1],
				disabledColor: this.conf.button.bgColor[2],
				selectedColor: this.conf.button.bgColor[3],
				width: this.conf.button.size[0],
				height: this.conf.button.size[1],
				font: this.fonts[1],
				textColor: this.conf.button.textColor,
				text: text,
			});
			return btn;
		}

		this.consoleBtn = makeButton("Console");
		this.consoleBtn.x = this.conf.padding;
		this.consoleBtn.y = this.conf.padding;
		this.consoleBtn.alpha = this.conf.alpha;
		this.consoleBtn.addOnClickListener("DebugOverlay", (_) -> {
			selectConsole();
		});
		this.addChild(this.consoleBtn);

		this.inspectorBtn = makeButton("Inspector");
		this.inspectorBtn.x = consoleBtn.getBounds().xMax + this.conf.spacing;
		this.inspectorBtn.y = consoleBtn.y;
		this.inspectorBtn.alpha = this.conf.alpha;
		this.inspectorBtn.addOnClickListener("DebugOverlay", (_) -> {
			selectInspector();
		});
		this.addChild(this.inspectorBtn);
	}

	function initConsole() {
		this.console = new OverlayConsole(this.fonts[0], this.game);
		this.console.conf.width = this.displayAreaWidth;
		this.console.conf.height = this.displayAreaHeight;
		this.console.conf.alpha = this.conf.alpha;
		this.console.conf.inputHeight = this.conf.console.inputHeight;
		this.console.x = this.conf.padding;
		this.console.y = this.displayAreaStartY;
		this.console.init();
		this.addChild(this.console);
	}

	function initInspector() {
		this.inspector = new OverlayInspector(this.fonts[0], this.game);
		this.inspector.conf.width = this.displayAreaWidth;
		this.inspector.conf.height = this.displayAreaHeight;
		this.inspector.conf.alpha = this.conf.alpha;
		this.inspector.x = this.conf.padding;
		this.inspector.y = this.displayAreaStartY;
		this.inspector.init();
		this.addChild(this.inspector);
	}

	public function selectConsole() {
		this.consoleBtn.toggled = true;
		this.inspectorBtn.toggled = false;
		this.console.visible = true;
		this.inspector.visible = false;
		this.console.onShow();
	}

	public function selectInspector() {
		this.consoleBtn.toggled = false;
		this.inspectorBtn.toggled = true;
		this.console.visible = false;
		this.inspector.visible = true;
		this.inspector.onShow();
	}

	public function hide() {
		this.visible = false;
	}

	public function show() {
		this.visible = true;
	}
}
