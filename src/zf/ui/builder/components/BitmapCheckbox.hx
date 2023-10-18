package zf.ui.builder.components;

class BitmapCheckboxComponent extends zf.ui.builder.Component {
	public function new() {
		super("bitmap-checkbox");
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
		for (i in 1...5) {
			var bm = context.getBitmap(zf.Access.struct({path: path, index: i}));
			if (bm == null) bm = context.getBitmap(zf.Access.struct({path: path, index: 0}));
			objects.push(bm);
		}

		final component = zf.ui.Checkbox.fromObjects({
			objects: objects,
		});
		return component;
	}
}
