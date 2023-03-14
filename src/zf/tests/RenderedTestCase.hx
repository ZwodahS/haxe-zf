package zf.tests;

import zf.h2d.HtmlText;
import zf.ui.UIElement;
import zf.h2d.Interactive;

using zf.HtmlUtils;

/**
	@stage:stable

	Wrap test cases to render onto the screen
**/
class RenderedTestCase extends UIElement {
	var screen: TestScreen;

	public var test: TestCase;

	public var testName(get, never): String;

	public var text: HtmlText;

	public var isSelected(default, set): Bool = false;

	public var started: Bool = false;

	public function set_isSelected(s: Bool): Bool {
		this.isSelected = s;
		this.updateText();
		return this.isSelected;
	}

	public function get_testName(): String {
		return this.test.name;
	}

	public function new(screen: TestScreen, test: TestCase) {
		super();
		this.screen = screen;
		this.test = test;

		this.text = new HtmlText(screen.fonts[1]);
		text.text = this.testName;
		text.textColor = screen.conf.testItem.text.defaultColor;
		final bounds = text.getBounds();

		this.interactive = new Interactive(Std.int(bounds.width), Std.int(bounds.height));

		this.addChild(text);
		this.addChild(interactive);

		test.onLogAdded = onLogAdded;
		test.onStateChanged = onStateChanged;
		updateText();
	}

	function updateText() {
		final conf = this.screen.conf.testItem.text;
		this.text.text = '';

		if (this.isSelected == true) {
			this.text.text += '${this.testName}'.font(conf.selectedColor);
		} else {
			this.text.text += '${this.testName}';
		}

		switch (this.test.state) {
			case Init:
				this.text.text += ' (Waiting)'.font(conf.waitingColor);
			case Running:
				this.text.text += ' (Running)'.font(conf.runningColor);
			case Completed:
				Assert.assert(this.test.result != null);
				if (this.test.result.success == true) {
					this.text.text += ' (Success)'.font(conf.successColor);
				} else {
					this.text.text += ' (Fail)'.font(conf.failureColor);
				}
		}
	}

	function onLogAdded(e: LogEntry) {
		if (this.isSelected == false) return;
		this.screen.renderNewLogEntry(e);
	}

	function onStateChanged(p, n) {
		updateText();
	}
}
