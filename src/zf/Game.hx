package zf;

import zf.debug.DebugOverlay;
import zf.h2d.HtmlText;

using zf.h2d.ObjectExtensions;

enum GameScreenState {
	InTransition;
	Ready;
}

/**
	@stage:stable

	Parent Game.hx
**/
class Game extends hxd.App {
	/**
		The width of the game
	**/
	public var gameWidth(get, null): Int;

	public function get_gameWidth(): Int {
		return this.s2d.width;
	}

	/**
		The height of the game
	**/
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

	/**
		The main display layer
	**/
	var display: h2d.Object;

	/**
		Mask things outside of the display area
	**/
	var mask: h2d.Mask;

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
		this.s2d.camera.clipViewport = true;

		this.mask = new h2d.Mask(this.boundedSize.x, this.boundedSize.y);
		this.mask.addChild(this.display = new h2d.Object());
		this.s2d.add(this.mask, 100);
#if debug
		this.setupFramerate();
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

	// ---- DebugOverlay ---- //

	/**
		This replace console and provide more functionality
	**/
#if debug
	var debugOverlay(default, set): DebugOverlay;

	function set_debugOverlay(overlay: DebugOverlay): DebugOverlay {
		this.debugOverlay = overlay;
		this.s2d.add(this.debugOverlay, 1000);
		@:privateAccess this.s2d.window.addEventTarget(debugOnEvent);

		return this.debugOverlay;
	}

	function debugOnEvent(event: hxd.Event) {
		if (this.debugOverlay != null) {
			switch (event.kind) {
				case EKeyDown:
					switch (event.keyCode) {
						case hxd.Key.F1:
							if (this.debugOverlay.visible == false) this.debugOverlay.show();
							this.debugOverlay.selectConsole();
						case hxd.Key.F2:
							if (this.debugOverlay.visible == false) this.debugOverlay.show();
							this.debugOverlay.selectInspector();
					}
				default:
			}
		}
	}

	var framerate: h2d.Text;
	var drawCalls: h2d.Text;

	function getDebugFont(): h2d.Font {
		var font = hxd.res.DefaultFont.get().clone();
		font.resizeTo(12);
		return font;
	}

	function setupFramerate() {
		var font: h2d.Font = getDebugFont();

		this.s2d.add(this.framerate = new HtmlText(font), 150);
		this.framerate.textAlign = Left;
		this.framerate.text = '0';
		this.framerate.x = 2;
		this.framerate.y = 2;
		this.framerate.visible = false;

		this.s2d.add(this.drawCalls = new HtmlText(font), 151);
		this.drawCalls.textAlign = Left;
		this.drawCalls.text = '0';
		this.drawCalls.putBelow(this.framerate, [0, 2]);
		this.drawCalls.visible = false;
	}
#end

	// ---- End of DebugOverlay ---- //

	override function update(dt: Float) {
#if debug
		if (this.framerate.visible == true) this.framerate.text = '${(1 / dt).round(1)}';
#end
		updateScreens(dt);
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

	/**
		Sun 22:06:50 07 May 2023
		Screen transitions is changed

		Sometimes we need to show the incoming and outgoing screen at the same time.
	**/
	public var currentScreen(default, null): zf.Screen;

	public var incomingScreen(default, null): zf.Screen;
	public var outgoingScreen(default, null): zf.Screen;
	public var isChangingScreen(get, never): Bool;

	inline function get_isChangingScreen() return this.outgoingScreen != null || this.incomingScreen != null;

	var screenState: GameScreenState;

	/**
		Switch to the screen.
		@param screen the screen to show
		@param showImmediately if true, the incoming screen will be added immediately
	**/
	public function switchScreen(screen: zf.Screen, showImmediately: Bool = false) {
		if (this.isChangingScreen == true) return;
		if (this.currentScreen == screen) return;

		// set the outgoing screen
		if (this.currentScreen != null) this.outgoingScreen = this.currentScreen;
		// set the incoming screen
		this.incomingScreen = screen;
		screen.game = this;
		// set current screen to null
		this.currentScreen = null;

		this.screenState = InTransition;
		if (showImmediately || this.outgoingScreen == null) {
			beginIncomingScreen();
		}

		if (this.outgoingScreen != null) {
			this.outgoingScreen.state = Exiting;
			this.outgoingScreen.beginScreenExit();
		}
	}

	function beginIncomingScreen() {
		this.incomingScreen.state = Entering;
		this.incomingScreen.beginScreenEnter();
		this.display.addChild(this.incomingScreen);
	}

	function screenExited(screen: zf.Screen) {}

	function screenEntered(screen: zf.Screen) {
		screen.resize(this.gameWidth, this.gameHeight);
	}

	function updateScreens(dt: Float) {
		try {
			if (this.currentScreen != null) this.currentScreen.update(dt);
			if (this.incomingScreen != null) this.incomingScreen.update(dt);
			if (this.outgoingScreen != null) this.outgoingScreen.update(dt);

			if (this.screenState == InTransition) {
				if (this.outgoingScreen != null && this.outgoingScreen.doneExiting() == true) {
					this.outgoingScreen.remove();
					this.outgoingScreen.onScreenExited();
					screenExited(this.outgoingScreen);
					this.outgoingScreen.state = Exited;
					this.outgoingScreen.destroy();
					this.outgoingScreen = null;

					// if the incoming is not added yet, means we did not add it immediately
					if (this.currentScreen == null && this.incomingScreen.parent == null) {
						beginIncomingScreen();
					}
				}
				if (this.incomingScreen != null && this.incomingScreen.parent != null
					&& this.incomingScreen.doneEntering() == true) {
					this.incomingScreen.onScreenEntered();
					this.incomingScreen.state = Ready;
					screenEntered(this.incomingScreen);
					this.currentScreen = this.incomingScreen;
					this.incomingScreen = null;
				}
				if (this.outgoingScreen == null && this.incomingScreen == null) this.screenState = Ready;
			}
		} catch (e) {
			Logger.exception(e);
			onException(e, haxe.CallStack.exceptionStack());
		}
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

/**
	Fri 10:49:27 06 Jan 2023
	I think the cursor position and debug stuffs should be moved into debug to make the code cleaner.
**/
