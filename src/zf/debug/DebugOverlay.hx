package zf.debug;

import zf.ui.UIElement;
import zf.h2d.HtmlText;
import zf.h2d.Interactive;
import zf.ui.Button;

import hxd.Key;

/**
	Motivation:

	Provide a debug overlay for various tooling that can be attach to the game

	- F1 (Console)
	- F2 (Variable Inspector)
**/
class DebugOverlay extends UIElement {
	public var game: Game;

	public var console: OverlayConsole;
	public var inspector: OverlayInspector;
	public var messages: OverlayMessages;

	public var conf = {
		alpha: 0.9,
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
		inspector: {
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

	var rect: zf.h2d.ScaleGrid;

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

		this.rect = new zf.h2d.ScaleGrid(h2d.Tile.fromColor(0xffffffff, 1, 1, 1), 1, 1, 1, 1);
		rect.alpha = .2;
		rect.width = 100;
		rect.height = 100;
		D.makeMovable(this.rect);
		D.makeResizable(this.rect);
	}

	public function init() {
		this.addChild(this.interactive = new Interactive(this.game.gameWidth, this.game.gameHeight));
		this.addOnKeyDownListener("DebugOverlay", (e) -> {
			if (this.visible == false) return;
			if (e.keyCode == Key.ESCAPE) hide();
			e.propagate = false;
		});
		this.interactive.propagateEvents = false;
		initButtons();
		initConsole();
		initInspector();
		initMessages();
		this.visible = false;

		selectConsole();
	}

	var consoleBtn: Button;
	var inspectorBtn: Button;
	var messagesBtn: Button;

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

		this.messagesBtn = makeButton("Messages");
		this.messagesBtn.x = this.inspectorBtn.getBounds().xMax + this.conf.spacing;
		this.messagesBtn.y = this.inspectorBtn.y;
		this.messagesBtn.alpha = this.conf.alpha;
		this.messagesBtn.addOnClickListener("DebugOverlay", (_) -> {
			selectMessages();
		});
		this.addChild(this.messagesBtn);
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
		this.console.hide = this.hide;

#if debug
		this.console.addCommand("debugRect", "Toggle debug rect", [], () -> {
			if (this.rect.parent != null) {
				hideDebugRect();
			} else {
				showDebugRect();
			}
		});

		this.console.addCommand("framerate", "Show Framerate", [], function() {
			@:privateAccess this.game.framerate.visible = !this.game.framerate.visible;
		});
#end
	}

	function initInspector() {
		this.inspector = new OverlayInspector(this.fonts[0], this.game);
		this.inspector.conf.width = this.displayAreaWidth;
		this.inspector.conf.height = this.displayAreaHeight;
		this.inspector.conf.alpha = this.conf.alpha;
		this.inspector.conf.inputHeight = this.conf.inspector.inputHeight;
		this.inspector.x = this.conf.padding;
		this.inspector.y = this.displayAreaStartY;
		this.inspector.init();
		this.addChild(this.inspector);
		this.inspector.hide = this.hide;
	}

	function initMessages() {
		this.messages = new OverlayMessages(this.fonts, this.game);
		this.messages.conf.width = this.displayAreaWidth;
		this.messages.conf.height = this.displayAreaHeight;
		this.messages.conf.alpha = this.conf.alpha;
		this.messages.x = this.conf.padding;
		this.messages.y = this.displayAreaStartY;
		this.messages.init();
		this.addChild(this.messages);
		this.messages.hide = this.hide;
	}

	public function selectConsole() {
		this.consoleBtn.toggled = true;
		this.inspectorBtn.toggled = false;
		this.messagesBtn.toggled = false;
		this.console.visible = true;
		this.inspector.visible = false;
		this.messages.visible = false;
		this.console.onShow();
	}

	public function selectInspector() {
		this.consoleBtn.toggled = false;
		this.inspectorBtn.toggled = true;
		this.messagesBtn.toggled = false;
		this.console.visible = false;
		this.inspector.visible = true;
		this.messages.visible = false;
		this.inspector.onShow();
	}

	public function selectMessages() {
		this.consoleBtn.toggled = false;
		this.inspectorBtn.toggled = false;
		this.messagesBtn.toggled = true;
		this.console.visible = false;
		this.inspector.visible = false;
		this.messages.visible = true;
		this.messages.onShow();
	}

	public function hide() {
		this.visible = false;
	}

	public function show() {
		this.visible = true;
	}

	public function showDebugRect() {
		this.game.s2d.addChild(this.rect);
	}

	public function hideDebugRect() {
		this.rect.remove();
	}
}
