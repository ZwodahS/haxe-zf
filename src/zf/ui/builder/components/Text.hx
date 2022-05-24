package zf.ui.builder.components;

using StringTools;

typedef TextConf = {
	/**
		font to use
	**/
	public var ?font: h2d.Font;

	/**
		fontName, to get from builder
	**/
	public var ?fontName: String;

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

class Text extends Component {
	public function new(type: String = "text") {
		super(type);
	}

	override public function makeFromXML(element: Xml): h2d.Object {
		final textObject = make(zf.Access.xml(element));
		var access = new haxe.xml.Access(element);
		var innerData: String = null;
		try {
			innerData = access.innerHTML;
		} catch (e) {
			return null;
		}
		if (innerData == null) return null;
		innerData = trimText(innerData.trim());
		textObject.text = formatString(innerData).replace("\n", "<br/>");
		return textObject;
	}

	function trimText(t: String): String {
		var strings = t.split("\n");
		strings = [for (s in strings) s.trim()];
		return strings.join("\n");
	}

	override public function makeFromStruct(c: Dynamic): h2d.Object {
		final conf: TextConf = c;
		final textObject = make(zf.Access.struct(conf));
		textObject.text = conf.text;
		return textObject;
	}

	function make(conf: zf.Access): h2d.HtmlText {
		var font: h2d.Font = null;
		if (conf.get("font") != null) font = cast(conf.get("font"));
		if (font == null) {
			font = getFont(conf.getString("fontName"));
		}

		final textColorString = conf.getString("textColor");
		var textColor: Color = 0xFFFFFF;
		if (textColorString != null) {
			final parsed = Std.parseInt(textColorString);
			if (parsed == null) {
				textColor = this.builder.getColor(textColorString);
			} else {
				textColor = parsed;
			}
		}

		final maxWidth = conf.getInt("maxWidth");

		final textObject = new h2d.HtmlText(font);
		textObject.textColor = textColor;
		if (maxWidth != null) textObject.maxWidth = maxWidth;

		switch (conf.getString("textAlign")) {
			case "center":
				textObject.textAlign = Center;
			case "left":
				textObject.textAlign = Left;
			case "right":
				textObject.textAlign = Right;
		}

		return textObject;
	}

	function getFont(name: String): h2d.Font {
		final font = name == null ? this.builder.defaultFont : this.builder.getFont(name);
		return font;
	}

	function formatString(str: String): String {
		return this.builder.formatString(str);
	}
}
