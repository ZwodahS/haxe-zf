package zf.ui.builder.components;

/**
	Create a Bitmap
	Wrap builder.getBitmap

	# Additional Attributes
	- scale=Int -> set bm.scaleX/bm.scaleY
	- path=String -> context.getBitmap()
	- index=Int -> context.getBitmap()
**/
class Bitmap extends Component {
	public function new() {
		super("bitmap");
	}

	override function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final bm = context.getBitmap(conf);

		if (conf.get("outline") != null) {
			final colorString = conf.getString("outline");
			final color = context.getColor(colorString);
			bm.filter = new zf.filters.PixelOutline(color);
		}

		if (conf.get("scale") != null) {
			final s = conf.getInt("scale");
			bm.scaleX = s;
			bm.scaleY = s;
		}

		return {object: bm};
	}
}
