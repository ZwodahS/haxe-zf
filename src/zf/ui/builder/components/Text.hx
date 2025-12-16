package zf.ui.builder.components;

import zf.h2d.Interactive;
import zf.h2d.HtmlText;
import zf.nav.StaticNavigationNode;

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

	# Navigation Attributes
	- nav="auto" -- other values are currently ignored.
	- navOnEnter="[string]"
			the handler function taken from BuilderContext
			the handler function must be (node: Xml, zf.h2d.HtmlText, BuilderContext) -> (Void -> Void)
	- navOnExit="[string]"
			the handler function taken from BuilderContext
			the handler function must be (node: Xml, zf.h2d.HtmlText, BuilderContext) -> (Void -> Void)
	- navOnActivate="[string]"
			the handler function taken from BuilderContext
			the handler function must be (node: Xml, zf.h2d.HtmlText, BuilderContext) -> (Void -> Void)

**/
class Text extends Component {
	public var defaultDropShadow: DropShadowConf = null;

	public function new(type: String = "text", defaultDropShadow: DropShadowConf = null) {
		super(type);
		this.defaultDropShadow = defaultDropShadow;
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);

		var font: h2d.Font = null;
		{ // Get Font
			if (conf.get("font") != null) font = cast(conf.get("font"));
			final fontName = conf.getString("fontName");
			if (font == null && fontName != null)
				font = context.data.get(fontName) ?? context.builder.getFont(fontName);
		}

		var textColor: Color = 0xFFFFFF;
		{ // Get Text Color
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
		}

		final textObject = new HtmlText(font);
		textObject.textColor = textColor;

		// Handle Max Width
		final maxWidth = conf.getInt("maxWidth");
		if (maxWidth != null) textObject.maxWidth = maxWidth;

		// Handle Text Align
		switch (conf.getString("textAlign")) {
			case "center":
				textObject.textAlign = Center;
			case "left":
				textObject.textAlign = Left;
			case "right":
				textObject.textAlign = Right;
		}

		// Handle Drop Shadow
		if (this.defaultDropShadow != null) textObject.dropShadow = this.defaultDropShadow;

		{ // Get Text
			// Handles string id, useful for localisation
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
					textObject.text = trimText(string);
				}
			} else {
				// if there is no stringId, we see if there are innerData that we need to display as block of text.
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
		}

		var navNode: StaticNavigationNode = null;
		if (element.get("nav") == "auto") { // Build Navigation Node
			final navOnEnter: (Xml, h2d.Object,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnEnter"));
			final navOnExit: (Xml, h2d.Object,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnExit"));
			final navOnActivate: (Xml, h2d.Object,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnActivate"));

			// @formatter:off
			navNode = UINavigationNode.alloc(
				navOnEnter == null ? null : navOnEnter(element, textObject, context),
				navOnExit == null ? null : navOnExit(element, textObject, context),
				navOnActivate == null ? null : navOnActivate(element, textObject, context)
			);

			navNode.name = 'TextNavNode: ${element.get("id")}';
		}

		if (element.get("onClick") != null) {
			// note that the bound for this is fixed
			final onClick: (Xml, h2d.Object, BuilderContext) -> (hxd.Event->Void) = context.get(element.get("onClick"));
			if (onClick != null) {
				final size = textObject.getSize();
				final interactive = new Interactive(size.width, size.height, textObject);
				interactive.propagateEvents = true;
				interactive.onPush = onClick(element, textObject, context);
				textObject.addChild(interactive);
			}
		}

		return {object: textObject, navNode: navNode};
	}

	function trimText(t: String, eol = "<br />"): String {
		t = t.trim();
		var strings = t.split("\n");
		strings = [for (s in strings) s.trim()];
		return strings.join(eol);
	}
}
