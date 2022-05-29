package zf.ui.builder.components;

typedef BitmapConf = {
	public var path: String;
}

class Bitmap extends Component {
	public function new() {
		super("bitmap");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		return getBitmap(element.get("path"), context);
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext) {
		final conf: BitmapConf = c;
		return getBitmap(conf.path, context);
	}

	function getBitmap(path: String, context: BuilderContext): h2d.Object {
		if (path == null) return new h2d.Object();
		if (context.builder.res == null) return new h2d.Object();

		final bm = context.builder.res.getBitmap(path);
		if (bm == null) return new h2d.Object();

		return bm;
	}
}
