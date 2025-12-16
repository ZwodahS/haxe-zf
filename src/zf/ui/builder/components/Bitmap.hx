package zf.ui.builder.components;

import zf.nav.StaticNavigationNode;
import zf.ui.builder.UINavigationNode;

/**
	Create a Bitmap
	Wrap builder.getBitmap

	# Additional Attributes
	- scale=Int -> set bm.scaleX/bm.scaleY
	- path=String -> context.getBitmap()
	- index=Int -> context.getBitmap()

	- pathId -> take the path value from context instead
	- indexId -> take the index value from context instead
**/
class Bitmap extends Component {
	public function new() {
		super("bitmap");
	}

	override function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		var bitmapConf: DynamicAccess<Dynamic> = {};

		if (conf.get("path") != null) {
			bitmapConf.set("path", conf.get("path"));
		} else if (conf.get("pathId") != null) {
			bitmapConf.set("path", context.get(conf.get("pathId")));
		} else {
			return null;
		}

		if (conf.get("index") != null) {
			bitmapConf.set("index", conf.get("index"));
		} else if (conf.get("indexId") != null) {
			bitmapConf.set("index", context.get(conf.get("indexId")));
		} else {
			bitmapConf.set("index", 0);
		}

		final bm = context.getBitmap(zf.Access.struct(bitmapConf));

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

		/**
			Mon 15:26:37 29 Dec 2025
			Not sure if this works yet.
		**/
		var navNode: StaticNavigationNode = null;
		if (element.get("nav") == "auto") { // Build Navigation Node
			final navOnEnter: (Xml, h2d.Bitmap,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnEnter"));
			final navOnExit: (Xml, h2d.Bitmap,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnExit"));
			final navOnActivate: (Xml, h2d.Bitmap,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnActivate"));

			// @formatter:off
			navNode = UINavigationNode.alloc(
				navOnEnter == null ? null : navOnEnter(element, cast bm, context),
				navOnExit == null ? null : navOnExit(element, cast bm, context),
				navOnActivate == null ? null : navOnActivate(element, cast bm, context)
			);

			navNode.name = 'BitmapNavNode: ${element.get("id")}';
		}

		return {object: bm, navNode: navNode};
	}
}
