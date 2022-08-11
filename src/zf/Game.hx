package zf;

using zf.h2d.ObjectExtensions;

/**
	Parent Game.hx
**/
enum ScreenState {
	Exiting;
	Entering;
	Ready;
}

#if debug
class TextLabel extends h2d.Object {
	public var text(default, set): String;

	var t: h2d.Text;
	var bm: h2d.Bitmap;
	var label: String;
	var size: Point2i;

	public function new(label: String, font: h2d.Font, size: Point2i) {
		super(null);
		this.label = label;
		this.size = size;
		var bm = new h2d.Bitmap(h2d.Tile.fromColor(0xAAAAAA, 1, 1));
		bm.alpha = .3;
		bm.width = size.x;
		bm.height = size.y;
		this.addChild(bm);
		this.t = new h2d.Text(font);
		this.addChild(this.t);
		this.text = '';
	}

	public function set_text(text: String): String {
		this.text = text;
		this.t.text = '${this.label}: ${text}';
		this.t.x = 1;
		this.t.y = (this.size.y - this.t.textHeight) / 2;
		return this.text;
	}
}
#end

class Game extends hxd.App {
	// ---- Proxy methods to scene ---- //
	public var gameWidth(get, null): Int;

	public function get_gameWidth(): Int {
		return this.s2d.width;
	}

	public var gameHeight(get, null): Int;

	public function get_gameHeight(): Int {
		return this.s2d.height;
	}

	/**
		The size to bound the game rendering.
	**/
	public var boundedSize(default, null): Point2i = null;

	public var pixelPerfect(default, set): Bool = false;

	public function set_pixelPerfect(p: Bool): Bool {
		this.pixelPerfect = p;
		if (this.screenState == Ready) updateScaleMode();
		return this.pixelPerfect;
	}

	var autoResize: Bool = true;

	public var r: hxd.Rand;

	override function new(size: Point2i = null, pixelPerfect: Bool = false, autoResize: Bool = true) {
		super();
		this.r = new hxd.Rand(Random.int(0, zf.Constants.SeedMax));
		if (size == null) size = [800, 600];
		this.pixelPerfect = pixelPerfect;
		this.boundedSize = size;
		this.autoResize = autoResize;
	}

	override function init() {
		// add event handler
		this.s2d.addEventListener(this.onEvent);
#if debug
		this.setupConsole();
		this.setupFramerate();
		this.setupCursor();
#end
		this.screenState = Ready;

		updateScaleMode();
	}

	function updateScaleMode() {
		// handle the common type of scene viewport
		if (!this.autoResize) {
			this.s2d.scaleMode = Fixed(this.boundedSize.x, this.boundedSize.y, 1.0);
		} else {
			if (this.pixelPerfect) {
				this.s2d.scaleMode = LetterBox(this.boundedSize.x, this.boundedSize.y, true, Center, Center);
			} else {
				this.s2d.scaleMode = LetterBox(this.boundedSize.x, this.boundedSize.y, false, Center, Center);
			}
		}
	}

#if debug
	var framerate: h2d.Text;
	var drawCalls: h2d.Text;
	var console: zf.Console;
	var consoleBg: h2d.Bitmap;

	function getDebugFont(): h2d.Font {
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(12);
		return font;
	}

	function setupFramerate() {
		var font: h2d.Font = getDebugFont();

		this.s2d.add(this.framerate = new h2d.HtmlText(font), 150);
		this.framerate.textAlign = Left;
		this.framerate.text = '0';
		this.framerate.x = 2;
		this.framerate.y = 2;
		this.framerate.visible = false;

		this.s2d.add(this.drawCalls = new h2d.HtmlText(font), 151);
		this.drawCalls.textAlign = Left;
		this.drawCalls.text = '0';
		this.drawCalls.putBelow(this.framerate, [0, 2]);
		this.drawCalls.visible = false;
	}

	function setupConsole() {
		var font = getDebugFont();

		this.consoleBg = new h2d.Bitmap(h2d.Tile.fromColor(1, 1, 1, 1));
		this.consoleBg.alpha = .5;
		this.consoleBg.tile.scaleToSize(s2d.width, s2d.height);
		this.consoleBg.visible = false;

		this.console = new Console(font, this);
		this.s2d.add(this.consoleBg, 999);
		this.s2d.add(console, 1000);

		this.console.addCommand("getWindowSize", "get the window size", [], function() {
			var window = hxd.Window.getInstance();
			this.console.log('Window Size: ${window.width},${window.height}');
		});

		this.console.addCommand("printString", "print a string",
			[{"name": "string", "t": h2d.Console.ConsoleArg.AString},], function(string) {
				this.console.log(string);
		});

		this.console.addCommand("mousePos", "Show mouse position", [], function() {
			this.cursorDetail.visible = !this.cursorDetail.visible;
		});
		this.console.addAlias("mp", "mousePos");

		this.console.addCommand("framerate", "toggle framerate", [], function() {
			this.framerate.visible = !this.framerate.visible;
			this.drawCalls.visible = !this.drawCalls.visible;
		});
		this.console.addAlias("fr", "framerate");

		this.console.addCommand("printObject", "print dynamic object fields",
			[{"name": "fields", "t": h2d.Console.ConsoleArg.AString},], this.printObject);
		this.console.addAlias("po", "printObject");
	}

	function printObject(fields: String) {
		var fieldSplit = fields.split(".");
		if (fieldSplit.length == 0) return;
		var objectName = fieldSplit[0];
		var obj: Dynamic = this.monitoredObjects == null ? null : this.monitoredObjects[objectName];
		if (obj == null) {
			this.console.log('Object ${objectName} Not monitored');
			return;
		}

		var i = 1;
		var value: Dynamic = obj;
		while (i < fieldSplit.length) {
			if (fieldSplit[i] == "") {} else {
				value = Reflect.getProperty(value, fieldSplit[i]);
				if (value == null) {
					this.console.log('null');
					return;
				}
			}
			i++;
		}
		try {
			var valueString = cast(value, String);
			for (s in valueString.split('\n')) {
				this.console.log('${s}');
			}
		} catch (e) {
			this.console.log('${value}');
		}
	}

	var monitoredObjects: Map<String, Dynamic>;

	public function monitorObject(obj: Dynamic, objectName: String) {
		if (this.monitoredObjects == null) this.monitoredObjects = new Map<String, Dynamic>();
		this.monitoredObjects[objectName] = obj;
	}

	public function unmonitorObject(objectName: String) {
		this.monitoredObjects.remove(objectName);
	}

	var cursorDetail: TextLabel;

	function setupCursor() {
		var font = getDebugFont();
		this.cursorDetail = new TextLabel("c", font, [100, 20]);
		this.cursorDetail.x = 2;
		this.cursorDetail.y = 2;
		this.s2d.add(cursorDetail, 101);
		this.cursorDetail.visible = false;
	}
#end

	// end of debug

	override function update(dt: Float) {
		try {
			if (this.currentScreen != null) this.currentScreen.update(dt);
			if (this.incomingScreen != null) this.incomingScreen.update(dt);
			if (this.outgoingScreen != null) this.outgoingScreen.update(dt);
#if debug
			this.framerate.text = '${zf.MathUtils.round(1 / dt, 1)}';
			if (this.cursorDetail.visible) this.cursorDetail.text = '(${s2d.mouseX}. ${s2d.mouseY})';
#end
			if (this.screenState == Exiting) {
				if (outgoingScreen.doneExiting()) {
					this.s2d.removeChild(this.outgoingScreen);
					this.outgoingScreen.onScreenExited();
					screenExited(this.outgoingScreen);
					this.outgoingScreen.destroy();
					this.outgoingScreen = null;
					if (this.incomingScreen != null) {
						beginIncommingScreen();
					} else {
						this.screenState = Ready;
					}
				}
			} else if (this.screenState == Entering) {
				if (this.incomingScreen.doneEntering()) {
					this.incomingScreen.onScreenEntered();
					screenEntered(this.incomingScreen);
					this.screenState = Ready;
					this.currentScreen = this.incomingScreen;
					this.incomingScreen = null;
				}
			}
		} catch (e) {
			onException(e, haxe.CallStack.exceptionStack());
		}
	}

	function onException(e: haxe.Exception, cs: Array<haxe.CallStack.StackItem>) {}

	function onEvent(event: hxd.Event) {
		if (this.currentScreen != null) this.currentScreen.onEvent(event);
	}

	override function render(engine: h3d.Engine) {
#if debug
		var t0 = haxe.Timer.stamp();
#end
		this.s2d.render(engine);
#if debug
		var drawTime = '${zf.StringUtils.formatFloat(haxe.Timer.stamp() - t0, 5)}s';
		this.drawCalls.text = 'draw: ${engine.drawCalls} (${drawTime})';
#end
	}

	// ---- Screen Management ---- //
	public var currentScreen(default, null): zf.Screen;
	public var incomingScreen(default, null): zf.Screen;
	public var outgoingScreen(default, null): zf.Screen;

	var screenState: ScreenState;

	public function switchScreen(screen: zf.Screen) {
		if (this.currentScreen == screen) return;
		if (this.currentScreen != null) this.outgoingScreen = this.currentScreen;
		screen.game = this;
		this.currentScreen = null;
		this.incomingScreen = screen;

		if (this.outgoingScreen != null) {
			this.screenState = Exiting;
			this.outgoingScreen.beginScreenExit();
		} else if (this.incomingScreen != null) {
			beginIncommingScreen();
		}
	}

	function beginIncommingScreen() {
		this.screenState = Entering;
		this.incomingScreen.beginScreenEnter();
		this.s2d.add(this.incomingScreen, 100);
	}

	function screenExited(screen: zf.Screen) {}

	function screenEntered(screen: zf.Screen) {
		screen.resize(this.gameWidth, this.gameHeight);
	}

	public function toggleFullScreen(fullscreen: Bool) {
		switch (fullscreen) {
			case true:
#if js
				hxd.Window.getInstance().displayMode = FullscreenResize;
#else
				hxd.Window.getInstance().displayMode = Borderless;
#end
			default:
				hxd.Window.getInstance().displayMode = Windowed;
		}
	}

	override function onResize() {
		if (this.currentScreen != null) this.currentScreen.resize(this.s2d.width, this.s2d.height);
	}
}
