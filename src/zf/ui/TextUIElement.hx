package zf.ui;

/**
	@stage:unstable

	Provide a UIElement that wrap a text.

	Goal is to make the interactive grow when the size of the text is updated

	Wed 11:08:41 22 Feb 2023
	The other events will be handled on a on need basis, i.e. updating font
**/
class TextUIElement extends UIElement {
	public var innerText: h2d.HtmlText;

	public var text(get, set): String;

	public function get_text(): String {
		return this.innerText.text;
	}

	public function set_text(v: String): String {
		this.innerText.text = v;
		_onTextUpdated();
		return this.innerText.text;
	}

	public function new(font: h2d.Font) {
		super();
		this.innerText = new h2d.HtmlText(font);

		this.interactive = new zf.h2d.Interactive(1, 1);
		this.addChild(this.interactive);
		this.addChild(this.innerText);

		this.innerText.text = '';
	}

	function _onTextUpdated() {
		if (this.interactive != null) {
			final bounds = this.innerText.getBounds();
			this.interactive.width = bounds.width;
			this.interactive.height = bounds.height;
		}
		onTextUpdated();
	}

	dynamic public function onTextUpdated() {}
}
