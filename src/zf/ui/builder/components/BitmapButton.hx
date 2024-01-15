package zf.ui.builder.components;

/**
	Mon 14:55:37 15 Jan 2024
	Probably can extend this and rename it to button later
**/
class BitmapButton extends zf.ui.builder.Component {
	public function new() {
		super("bitmap-button");
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): h2d.Object {
		return make(zf.Access.struct(s), context);
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		return make(zf.Access.xml(element), context);
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Object {
		final path = conf.getString("bitmapId");
		final objects: Array<h2d.Object> = [];
		final defaultBitmap = context.getBitmap(zf.Access.struct({path: path, index: 0}));
		if (defaultBitmap == null) return null;
		objects.push(defaultBitmap);
		for (i in 1...4) {
			var bm = context.getBitmap(zf.Access.struct({path: path, index: i}));
			if (bm == null) bm = defaultBitmap;
			objects.push(bm);
		}

		var font: h2d.Font = null;
		final fontName = conf.getString("fontName");
		if (fontName != null) {
			font = context.getFont(fontName);
		}

		final floatOffset: Point2f = [0, 0];
		final floatX = conf.getFloat("float-x");
		final floatY = conf.getFloat("float-y");
		if (floatX != null) floatOffset.x = floatX;
		if (floatY != null) floatOffset.y = floatY;

		final textColorString = conf.getString("textColor");
		final textColor: Null<Color> = textColorString == null ? null : context.getColor(textColorString);

		final buttonLabelString = conf.getString("textId");
		final text = buttonLabelString == null ? null : context.getString(buttonLabelString, {});

		final component = zf.ui.Button.fromObjects({
			objects: objects,
			font: font,
			floatOffset: floatOffset,
			textColor: textColor,
			text: text,
		});

		if (conf.get("onClick") != null) {
			try {
				final func: hxd.Event->Void = context.data.get(conf.get("onClick"));
				if (func != null) component.addOnLeftClickListener("BitmapButton", func);
			} catch (e) {}
		}

		return component;
	}
}
