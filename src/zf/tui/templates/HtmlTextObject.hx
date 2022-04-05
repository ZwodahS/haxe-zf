package zf.tui.templates;

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
		final text = new h2d.HtmlText(conf.font);
		text.text = conf.text;
		if (conf.textColor != null) text.textColor = conf.textColor;
		if (conf.maxWidth != null) text.maxWidth = conf.maxWidth;
		if (conf.textAlign != null) {
			switch (conf.textAlign) {
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
