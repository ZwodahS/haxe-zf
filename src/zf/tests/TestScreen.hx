package zf.tests;

import zf.ui.ScrollBar;
import zf.h2d.Interactive;
import zf.ui.ScaleGridFactory;

using zf.h2d.ObjectExtensions;
using zf.HtmlUtils;

using StringTools;

/**
	@stage:unstable

	Provide a common TestScreen that can be used across all games to run test cases.
	The test cases can be a normal test case or even simulation of worlds.
**/
class TestScreen extends zf.Screen {
	// ---- Configuration ---- //

	/**
		The number of concurrent test runner
	**/
	public var concurrent(default, set) = 1;

	public function set_concurrent(c: Int) {
		this.concurrent = c;
		// let's check how many we have
		final currentCount = this.runners.length;
		// if we arleady have enough, return
		if (currentCount >= this.concurrent) return this.concurrent;
		// for each missing, add it to the runner
		for (_ in 0...(this.concurrent - currentCount)) {
			final runner = new TestRunner();
			this.runners.push(runner);
			this.freeRunners.push(runner);
			runner.onTestCaseCompleted = this.onTestCaseCompleted.bind(runner);
		}

		Assert.assert(this.runners.length == this.concurrent);
		return this.concurrent;
	}

	/**
		Configure the colors of various ui components
	**/
	// @todo change the default color to non-bland colors :)

	/**
		The default conf here is based on the screen resolution 640, 320
	**/
	public var conf = {
		bgColor: 0xff111012,
		scrollBar: {
			color: 0xff111012,
			cursorWidth: 2,
			barWidth: 6,
			yPadding: 5,
			xPadding: 2,
			scrollDirection: 1,
		},
		logsWindow: {
			bounds: {
				width: 300,
				height: 300,
				x: 330,
				y: 10
			},
			background: 0xfffffbe5,
			text: {
				xSpacing: 5,
				ySpacing: 5,
				lineSpacing: 2,
				defaultColor: 0xff111012,
				warnColor: 0xfff7a37c,
				errorColor: 0xffe67a73,
			},
		},
		testsWindow: {
			bounds: {
				width: 180,
				height: 200,
				x: 10,
				y: 110
			},
			background: 0xfffffbe5,
			xSpacing: 5,
			ySpacing: 5,
			verticalSpacing: 2,
		},
		testItem: {
			text: {
				defaultColor: 0xff111012,
				selectedColor: 0xff88867c,
				waitingColor: 0xff4e90a8,
				runningColor: 0xff5eb0ce,
				successColor: 0xff5ca153,
				failureColor: 0xffe67a73,
			}
		}
	}

	public var uiScale(default, set): Int = 1;

	public function set_uiScale(s: Int): Int {
		this.uiScale = s;
		this.conf.scrollBar.cursorWidth *= s;
		this.conf.scrollBar.barWidth *= s;
		this.conf.scrollBar.yPadding *= s;
		this.conf.scrollBar.xPadding *= s;

		this.conf.logsWindow.bounds.width *= s;
		this.conf.logsWindow.bounds.height *= s;
		this.conf.logsWindow.bounds.x *= s;
		this.conf.logsWindow.bounds.y *= s;
		this.conf.logsWindow.text.xSpacing *= s;
		this.conf.logsWindow.text.ySpacing *= s;
		this.conf.logsWindow.text.lineSpacing *= s;

		this.conf.testsWindow.bounds.x *= s;
		this.conf.testsWindow.bounds.y *= s;
		this.conf.testsWindow.bounds.width *= s;
		this.conf.testsWindow.bounds.height *= s;
		this.conf.testsWindow.xSpacing *= s;
		this.conf.testsWindow.ySpacing *= s;
		this.conf.testsWindow.verticalSpacing *= s;
		return this.uiScale;
	}

	public var fonts: Array<h2d.Font>;

	// ---- Data ---- //

	/**
		Store all the test cases
	**/
	public var tests: Array<RenderedTestCase>;

	/**
		The test cases that are incomplete
	**/
	public var incomplete: Array<RenderedTestCase>;

	/**
		Store all the test cases that are available.

		All test case's constructor should only take 1 argument, which is the testId
	**/
	public var availableTests: Map<String, (String) -> TestCase>;

	var runners: Array<TestRunner>;
	var freeRunners: Array<TestRunner>;

	public var selectedTest: RenderedTestCase = null;

	// ---- UI stuffs ---- //

	/**
		The main layer that is drawn. Allow me to toggle visibility of all the control elements
	**/
	var gameLayers: h2d.Layers;

	var controlLayers: h2d.Layers;

	var logsWindowBG: h2d.Object;
	var logsDisplayArea: h2d.Object;
	var logsText: h2d.HtmlText;
	var logsScrollMask: h2d.Mask;
	var logsScrollBar: ScrollBar;

	var testsWindowBG: h2d.Object;
	var testsDisplayArea: h2d.Flow;
	var testsScrollMask: h2d.Mask;
	var testsScrollBar: ScrollBar;

	public var ready(default, null): Bool = false;

	public function new() {
		super();
		this.tests = [];
		this.incomplete = [];
		this.availableTests = [];
		this.runners = [];
		this.freeRunners = [];
		this.concurrent = 1;

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

	public function addTestCase(name: String, makeFunc: String->TestCase) {
		this.availableTests[name] = makeFunc;
	}

	function setupUI() {
		this.controlLayers = new h2d.Layers();
		final bg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		bg.alpha = 0.6;
		bg.width = this.game.gameWidth;
		bg.height = this.game.gameHeight;
		this.controlLayers.add(bg, 0);

		final block = new Interactive(Std.int(this.game.gameWidth), Std.int(this.game.gameHeight));
		block.propagateEvents = false;
		block.onKeyDown = (e) -> {
			switch (e.kind) {
				case EKeyDown:
					if (e.keyCode == 27) toggleControlVisibility();
				default:
			}
		}
		this.controlLayers.add(block, 1);

		setupLogs();
		setupTestList();

		this.add(this.gameLayers = new h2d.Layers(), 50);
		this.add(this.controlLayers, 100);
	}

	// ---- LogsWindow ---- //
	function setupLogs() {
		final gameWidth = this.game.gameWidth;
		final gameHeight = this.game.gameHeight;

		final display = new h2d.Object();
		this.logsDisplayArea = new h2d.Object();

		final windowBounds = this.conf.logsWindow.bounds;

		final logsWindowBG = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.logsWindow.background));
		logsWindowBG.width = windowBounds.width;
		logsWindowBG.height = windowBounds.height;
		this.logsWindowBG = logsWindowBG;
		display.addChild(logsWindowBG);

		final text = new h2d.HtmlText(this.fonts[1]);
		text.maxWidth = windowBounds.width
			- (this.conf.logsWindow.text.xSpacing * 2)
			- this.conf.scrollBar.barWidth
			- 6;
		text.textColor = this.conf.logsWindow.text.defaultColor;
		text.lineSpacing = this.conf.logsWindow.text.lineSpacing;
		text.x = logsWindowBG.x + this.conf.logsWindow.text.xSpacing;
		text.y = logsWindowBG.y + this.conf.logsWindow.text.ySpacing;
		this.logsText = text;
		logsDisplayArea.addChild(text);

		this.logsScrollMask = new h2d.Mask(windowBounds.width, windowBounds.height);
		this.logsScrollMask.addChild(logsDisplayArea);
		var bound = new h2d.col.Bounds();
		bound.xMin = 0;
		bound.yMin = 0;
		bound.xMax = windowBounds.width;
		bound.yMax = windowBounds.height;
		this.logsScrollMask.scrollBounds = bound;
		this.logsScrollMask.scrollY = 0;
		display.addChild(this.logsScrollMask);

		var interactive = new Interactive(windowBounds.width, windowBounds.height, display);
		interactive.onWheel = function(e) {
			this.logsScrollMask.scrollY += 30 * e.wheelDelta;
		}

		this.logsScrollBar = new ScrollBar();
		final t = h2d.Tile.fromColor(this.conf.scrollBar.color);
		this.logsScrollBar.cursorFactory = new ScaleGridFactory(t, 0, 0, 0, 0);
		this.logsScrollBar.scrollCursorWidth = this.conf.scrollBar.cursorWidth;
		this.logsScrollBar.maxHeight = windowBounds.height - (this.conf.scrollBar.yPadding * 2);
		this.logsScrollBar.y = this.conf.scrollBar.yPadding;
		this.logsScrollBar.setX(windowBounds.width - this.conf.scrollBar.xPadding - this.conf.scrollBar.barWidth);
		this.logsScrollBar.scrollBarWidth = this.conf.scrollBar.barWidth;
		this.logsScrollBar.attachTo(this.logsScrollMask);
		display.addChild(this.logsScrollBar);

		display.x = windowBounds.x;
		display.y = windowBounds.y;
		this.controlLayers.addChild(display);
	}

	function onTextUpdated(updateScroll: Bool = true) {
		final bounds = this.logsWindowBG.getBounds();
		bounds.xMin = 0;
		bounds.yMin = 0;
		bounds.xMax = bounds.xMax;
		bounds.yMax = Math.max(bounds.yMax, this.logsDisplayArea.getSize().height) + 10;
		this.logsScrollMask.scrollBounds = bounds;
		if (updateScroll == true) this.logsScrollMask.scrollY = 0;
		this.logsScrollBar.onMaskUpdate();
	}

	// ---- TestList ---- //
	function setupTestList() {
		final gameWidth = this.game.gameWidth;
		final gameHeight = this.game.gameHeight;

		final display = new h2d.Object();

		final windowBounds = this.conf.testsWindow.bounds;

		final windowsBG = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.testsWindow.background));
		windowsBG.width = windowBounds.width;
		windowsBG.height = windowBounds.height;
		display.addChild(windowsBG);
		this.testsWindowBG = windowsBG;

		this.testsDisplayArea = new h2d.Flow();
		this.testsDisplayArea.layout = Vertical;
		this.testsDisplayArea.horizontalAlign = Left;
		this.testsDisplayArea.verticalSpacing = this.conf.testsWindow.verticalSpacing;
		this.testsDisplayArea.x = this.conf.testsWindow.xSpacing;
		this.testsDisplayArea.y = this.conf.testsWindow.ySpacing;

		this.testsScrollMask = new h2d.Mask(windowBounds.width, windowBounds.height);
		this.testsScrollMask.addChild(this.testsDisplayArea);
		var bound = new h2d.col.Bounds();
		bound.xMin = 0;
		bound.yMin = 0;
		bound.xMax = windowBounds.width;
		bound.yMax = windowBounds.height;
		this.testsScrollMask.scrollBounds = bound;
		this.testsScrollMask.scrollY = 0;
		display.addChild(this.testsScrollMask);

		var interactive = new Interactive(windowBounds.width, windowBounds.height, display);
		interactive.onWheel = function(e) {
			this.testsScrollMask.scrollY += 30 * e.wheelDelta;
		}
		interactive.propagateEvents = true;

		this.testsScrollBar = new ScrollBar();
		final t = h2d.Tile.fromColor(this.conf.scrollBar.color);
		this.testsScrollBar.cursorFactory = new ScaleGridFactory(t, 0, 0, 0, 0);
		this.testsScrollBar.scrollCursorWidth = this.conf.scrollBar.cursorWidth;
		this.testsScrollBar.maxHeight = windowBounds.height - (this.conf.scrollBar.yPadding * 2);
		this.testsScrollBar.y = this.conf.scrollBar.yPadding;
		this.testsScrollBar.setX(windowBounds.width - this.conf.scrollBar.xPadding - this.conf.scrollBar.barWidth);
		this.testsScrollBar.scrollBarWidth = this.conf.scrollBar.barWidth;
		this.testsScrollBar.attachTo(this.testsScrollMask);
		display.addChild(this.testsScrollBar);

		display.x = windowBounds.x;
		display.y = windowBounds.y;
		this.controlLayers.addChild(display);
	}

	/**
		This only trigger when new tests are added or removed from the list
	**/
	function onTestListUpdated() {
		final bounds = this.logsWindowBG.getBounds();
		bounds.xMin = 0;
		bounds.yMin = 0;
		bounds.xMax = bounds.xMax;
		bounds.yMax = Math.max(bounds.yMax, this.testsDisplayArea.getSize().height) + (10 * this.uiScale);
		this.testsScrollMask.scrollBounds = bounds;
		this.testsScrollMask.scrollY = 0;
		this.testsScrollBar.onMaskUpdate();
	}

	public function runCommand(args: Array<String>) {
		{
			final i = args.indexOf("-c");
			if (i != -1) {
				this.concurrent = Std.parseInt(args[i + 1]);
				args.splice(i, 2);
			}
		}

		if (args.indexOf("--all") != -1) {
			runTests(availableTests.keys());
			return;
		}

		final toRun = new Map<String, Bool>();
		for (tn in args) {
			if (tn.endsWith(".*")) {
				final match = tn.substr(0, tn.length - 2);
				for (tid => _ in this.availableTests) {
					if (tid.startsWith(match)) toRun[tid] = true;
				}
			} else if (this.availableTests[tn] != null) {
				toRun[tn] = true;
			}
		}

		runTests(toRun.keys());
	}

	function runTests(tests: Iterator<String>) {
		for (t in tests) {
			final tc = availableTests[t];
			if (tc == null) continue;

			final test = tc('${this.game.r.randomInt(zf.Constants.SeedMax)}');

			final rtc = new RenderedTestCase(this, test);
			bindTest(rtc);
			this.testsDisplayArea.addChild(rtc);

			this.tests.push(rtc);
			this.incomplete.push(rtc);
		}
		onTestListUpdated();
	}

	function bindTest(rtc: RenderedTestCase) {
		rtc.addOnClickListener("TestScreen", (e) -> {
			toggleTest(rtc);
		});
	}

	function toggleTest(rtc: RenderedTestCase) {
		var previous = this.selectedTest;
		if (this.selectedTest != null) deselectTest();
		onTestCaseSelected(null);
		if (previous == rtc) return;
		this.selectedTest = rtc;
		this.selectedTest.isSelected = true;
		renderLogs(rtc.test);
		final ro = this.selectedTest.test.renderLayers;
		if (ro != null) this.gameLayers.addChild(ro);
		onTestCaseSelected(this.selectedTest.test);
	}

	function renderLogs(tc: TestCase) {
		final strs: Array<String> = [];

		for (entry in tc.logs) {
			strs.push(formatLogEntry(entry));
		}
		this.logsText.text = strs.join('<br/>');
		this.onTextUpdated();
	}

	function formatLogEntry(entry: LogEntry) {
		if (entry.level == 0) return entry.message;
		final color: Color = switch (entry.level) {
			case 50: this.conf.logsWindow.text.warnColor;
			case 100: this.conf.logsWindow.text.errorColor;
			default: this.conf.logsWindow.text.defaultColor;
		}
		return entry.message.font(color);
	}

	public function renderNewLogEntry(entry: LogEntry) {
		// @untested
		this.logsText.text += '<br/>' + formatLogEntry(entry);
		this.onTextUpdated(false);
	}

	function deselectTest() {
		this.selectedTest.isSelected = false;
		// @todo remove rendering if any
		this.selectedTest = null;
		this.gameLayers.removeChildren();
		this.logsText.text = '';
		this.onTextUpdated();
	}

	override public function update(dt: Float) {
		if (this.ready == false) return;

		for (runner in this.runners) {
			runner.update(dt);
		}

		// handle selected test separately if there is no runner attached to it
		if (this.selectedTest != null) {
			if (this.selectedTest.test.runner == null && this.selectedTest.test.state != Init) {
				try {
					if (this.selectedTest.test.updateException == false) this.selectedTest.test.update(dt);
				} catch (e) {
					this.selectedTest.test.updateException = true;
					Logger.exception(e);
				}
			}
		}

		// check if there are any free runners and incomplete test to start a new one
		if (this.incomplete.length == 0) return;
		if (this.freeRunners.length == 0) return;

		// pick one and start
		final tc = this.incomplete.shift();
		final runner = this.freeRunners.shift();
		Assert.assert(runner.current == null);
		runner.runTest(tc.test);
	}

	function onTestCaseCompleted(runner: TestRunner, testcase: TestCase, testResult: TestResult) {
		// if the concurrent value is < runners, i.e. scaling down, we don't add it back to freeRunners.
		// instead we remove it from runners
		if (this.concurrent < this.runners.length) {
			this.runners.remove(runner);
		} else {
			// return it back to free runners
			this.freeRunners.push(runner);
		}
	}

	override public function onEvent(event: hxd.Event) {
		for (runner in this.runners) {
			// runner.onEvent(event);
		}
		if (this.selectedTest != null) {
			if (this.selectedTest.test.runner == null && this.selectedTest.test.state != Init) {
				try {
					this.selectedTest.test.onEvent(event);
				} catch (e) {
					Logger.exception(e);
				}
			}
		}
		switch (event.kind) {
			case EKeyDown:
				if (event.keyCode == 27) toggleControlVisibility();
			default:
		}
	}

	function toggleControlVisibility() {
		this.controlLayers.visible = !this.controlLayers.visible;
	}

	override public function destroy() {}

	override function doneExiting() {
		return true;
	}

	public function finalise() {
		setupUI();
	}

	override public function beginScreenEnter() {}

	override public function onScreenEntered() {
		this.ready = true;
	}

	override public function onScreenExited() {}

	dynamic public function onTestCaseSelected(testcase: TestCase) {}
}
