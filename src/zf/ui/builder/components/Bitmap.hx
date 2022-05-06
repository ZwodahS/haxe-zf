package zf.ui.builder.components;

typedef BitmapConf = {
	public var path: String;
}

class Bitmap extends Component {
	public function new() {
		super("bitmap");
	}

	override public function makeFromXML(element: Xml): h2d.Object {
		return getBitmap(element.get("path"));
	}

	override public function makeFromStruct(c: Dynamic) {
		final conf: BitmapConf = c;
		return getBitmap(conf.path);
	}

	function getBitmap(path: String): h2d.Object {
		if (path == null) return new h2d.Object();
		if (this.builder.res == null) return new h2d.Object();

		final bm = this.builder.res.getBitmap(path);
		if (bm == null) return new h2d.Object();

		return bm;
	}
}
