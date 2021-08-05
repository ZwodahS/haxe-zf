package zf.ui;

using zf.HtmlUtils;

class TextButton extends h2d.Object {
	var label: h2d.HtmlText;

	public var text(default, set): String = '';

	public function set_text(text: String): String {
		this.text = text;
		this.label.text = text;
		this.interactive.width = this.label.textWidth;
		this.interactive.height = this.label.textHeight;
		this.width = this.label.textWidth;
		this.height = this.label.textHeight;
		updateText();
		return this.text;
	}

	var width: Float;
	var height: Float;
	var defaultColor: Int;
	var hoverColor: Int;
	var isHovered: Bool = false;
	var interactive: h2d.Interactive;

	public function new(defaultColor: Int, hoverColor: Int, text: String, font: h2d.Font) {
		super();
		this.label = new h2d.HtmlText(font);
		this.defaultColor = defaultColor;
		this.hoverColor = hoverColor;

		updateText();

		this.addChild(label);

		this.width = this.label.textWidth;
		this.height = this.label.textHeight;
		this.interactive = new h2d.Interactive(width, height, this);
		this.interactive.onOver = function(e: hxd.Event) {
			this.isHovered = true;
			updateText();
		}
		this.interactive.onOut = function(e: hxd.Event) {
			this.isHovered = false;
			updateText();
		}
		this.interactive.onRelease = function(e: hxd.Event) {
			onRelease();
		}
		this.interactive.onClick = function(e: hxd.Event) {
			if (e.button == 0) {
				onLeftClick();
			} else if (e.button == 1) {
				onRightClick();
			}
			onClick(e.button);
		}
		this.interactive.cursor = Default;
		this.text = text;
	}

	function updateText() {
		var color = this.isHovered ? this.hoverColor : this.defaultColor;
		this.label.text = '${this.text.font(color)}';
	}

	dynamic public function onClick(button: Int) {}

	dynamic public function onLeftClick() {}

	dynamic public function onRightClick() {}

	dynamic public function onRelease() {}
}
