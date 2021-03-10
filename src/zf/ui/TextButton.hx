package zf.ui;

using zf.HtmlUtils;

import zf.AlignmentUtils;

class TextButton extends h2d.Object {
	var label: h2d.HtmlText;
	var text: String;

	var width: Float;
	var height: Float;
	var defaultColor: Int;
	var hoverColor: Int;
	var isHovered: Bool = false;

	public function new(defaultColor: Int, hoverColor: Int, text: String, font: h2d.Font) {
		super();
		this.text = text;
		this.label = new h2d.HtmlText(font);
		this.defaultColor = defaultColor;
		this.hoverColor = hoverColor;

		updateText();

		this.addChild(label);

		this.width = this.label.textWidth;
		this.height = this.label.textHeight;
		var interactive = new h2d.Interactive(width, height, this);
		interactive.onOver = function(e: hxd.Event) {
			this.isHovered = true;
			updateText();
		}
		interactive.onOut = function(e: hxd.Event) {
			this.isHovered = false;
			updateText();
		}
		interactive.onRelease = function(e: hxd.Event) {
			onClick();
		}
		interactive.cursor = Default;
	}

	function updateText() {
		var color = this.isHovered ? this.hoverColor : this.defaultColor;
		this.label.text = '${this.text.font(color)}';
	}

	dynamic public function onClick() {}
}
