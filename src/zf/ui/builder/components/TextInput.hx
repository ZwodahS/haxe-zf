package zf.ui.builder.components;

using zf.ds.ArrayExtensions;

using StringTools;

private typedef DropShadowConf = {dx: Float, dy: Float, color: Int, alpha: Float};

/**
	Create HTML Text component

	# Attributes
	- font=h2d.Font
	- fontName=String -> context.builder.getFont
	- textColorKey=String -> context.get(textColorKey)
	- textColor=String
	- maxWidth -> h2d.HtmlText.maxWidth
	- textAlign=["center"|"left"|"right"]
	- stringId=String -> context.get(stringId) ?? context.builder.getStringTemplate(stringId)
**/
class TextInput extends Component {
	public var defaultDropShadow: DropShadowConf = null;

	public function new(type: String = "text-input", defaultDropShadow: DropShadowConf = null) {
		super(type);
		this.defaultDropShadow = defaultDropShadow;
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		var font: h2d.Font = null;
		if (conf.get("font") != null) font = cast(conf.get("font"));
		if (font == null) {
			font = context.builder.getFont(conf.getString("fontName"));
		}
		final disableEdit = conf.getBool("disableEdit");

		var textColor: Color = 0xFFFFFF;

		final textColorKey = conf.getString("textColorKey");
		var textColorString: String = null;
		if (textColorKey != null) {
			textColorString = context.get(textColorKey);
		} else {
			textColorString = conf.getString("textColor");
		}

		if (textColorString != null) {
			final parsed = Std.parseInt(textColorString);
			if (parsed == null) {
				textColor = context.builder.getColor(textColorString);
			} else {
				textColor = parsed;
			}
		}

		final maxWidth = conf.getInt("maxWidth");
		final inputWidth = conf.getInt("inputWidth");
		final backgroundColor = conf.get("backgroundColor");

		final textObject = new h2d.TextInput(font);
		textObject.textColor = textColor;
		if (maxWidth != null) textObject.maxWidth = maxWidth;
		if (inputWidth != null) textObject.inputWidth = inputWidth;
		if (backgroundColor != null) textObject.backgroundColor = backgroundColor;
		if (disableEdit == true) textObject.canEdit = false;

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

		// handles string id, useful for localisation
		if (conf.get("stringId") != null) {
			final stringId = conf.get("stringId");
			// take from context first if the string Id exist
			var string: String = cast context.get(stringId);
			// if stringId not found, we take it from the builder's StringTemplate
			if (string == null) {
				final template = context.builder.getStringTemplate(stringId);
				if (template != null) string = context.formatTemplate(template);
			} else {
				string = context.formatTemplate(new haxe.Template(string));
			}
			if (string != null) {
				textObject.text = trimText(string, "<br />");
			}
		} else {
			var access = new haxe.xml.Access(element);
			var innerData: String = null;
			try {
				innerData = access.innerHTML;
				if (innerData != null) {
					innerData = trimText(innerData.trim());
					textObject.text = context.formatString(innerData).replace("\n", "<br/>");
				}
			} catch (e) {}
		}

		return {object: textObject};
	}

	function trimText(t: String, eol = "<br />"): String {
		t = t.trim();
		var strings = t.split("\n");
		strings = [for (s in strings) s.trim()];
		return strings.join(eol);
	}
}
