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

typedef DropShadowConf = {dx: Float, dy: Float, color: Int, alpha: Float};

class Text extends Component {
	public var defaultDropShadow: DropShadowConf = null;

	public function new(type: String = "text", defaultDropShadow: DropShadowConf = null) {
		super(type);
		this.defaultDropShadow = defaultDropShadow;
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final textObject = make(zf.Access.xml(element), context);
		var access = new haxe.xml.Access(element);
		var innerData: String = null;
		try {
			innerData = access.innerHTML;
		} catch (e) {
			return null;
		}
		if (innerData == null) return null;
		innerData = trimText(innerData.trim());
		textObject.text = context.formatString(innerData).replace("\n", "<br/>");
		return textObject;
	}

	function trimText(t: String): String {
		var strings = t.split("\n");
		strings = [for (s in strings) s.trim()];
		return strings.join("\n");
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: TextConf = c;
		if (conf.text == null) return null;
		final textObject = make(zf.Access.struct(conf), context);
		textObject.text = context.formatString(trimText(conf.text));
		return textObject;
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.HtmlText {
		var font: h2d.Font = null;
		if (conf.get("font") != null) font = cast(conf.get("font"));
		if (font == null) {
			font = context.builder.getFont(conf.getString("fontName"));
		}

		final textColorString = conf.getString("textColor");
		var textColor: Color = 0xFFFFFF;
		if (textColorString != null) {
			final parsed = Std.parseInt(textColorString);
			if (parsed == null) {
				textColor = context.builder.getColor(textColorString);
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

		if (this.defaultDropShadow != null) {
			textObject.dropShadow = this.defaultDropShadow;
		}

		return textObject;
	}
}
