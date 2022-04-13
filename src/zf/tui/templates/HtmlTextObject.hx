package zf.tui.templates;

using zf.tui.templates.HtmlTextObject;

typedef HtmlTextObjectConf = {
	/**
		font to use
	**/
	public var font: h2d.Font;

	/**
		text to display
	**/
	public var text: String;

	/**
		default color of the text
	**/
	public var ?textColor: Int;

	/**
		max width
	**/
	public var ?maxWidth: Int;

	/**
		text alignment
	**/
	public var ?textAlign: String;
}

class HtmlTextObject extends Template {
	public function new() {
		super("htmltext");
	}

	override public function make(c: Dynamic): h2d.HtmlText {
		final conf: HtmlTextObjectConf = c;
		return h2d.HtmlText.fromTemplate(conf);
	}

	public static function fromTemplate(cls: Class<h2d.HtmlText>, template: HtmlTextObjectConf): h2d.HtmlText {
		final text = new h2d.HtmlText(template.font);
		text.text = template.text;
		if (template.textColor != null) text.textColor = template.textColor;
		if (template.maxWidth != null) text.maxWidth = template.maxWidth;
		if (template.textAlign != null) {
			switch (template.textAlign) {
				case "center":
					text.textAlign = Center;
				case "left":
					text.textAlign = Left;
				case "right":
					text.textAlign = Right;
			}
		}
		return text;
	}
}
