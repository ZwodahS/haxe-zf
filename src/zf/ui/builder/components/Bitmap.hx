package zf.ui.builder.components;

/**
	@stage:stable
**/
class Bitmap extends Component {
	public function new() {
		super("bitmap");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		return make(zf.Access.xml(element), context);
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext) {
		return make(zf.Access.struct(c), context);
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Object {
		final bm = context.getBitmap(conf);
		if (conf.get("name") != null) {
			Logger.debug("[Deprecated] name is deprecated for component, use id instead");
			bm.name = conf.get("name");
		}
		if (conf.get("scale") != null) {
			final s = conf.getInt("scale");
			bm.scaleX = s;
			bm.scaleY = s;
		}
		return bm;
	}
}
