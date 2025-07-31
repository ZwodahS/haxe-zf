package zf.ui.builder.components;

/**
	Create a Scalegrid

	# Attributes
	- factoryId=String -> context.builder.getScaleGridFactory(factoryId)
	- width=Int
	- height=Int
	- color=String -> context.getColor(color)
**/
class ScaleGrid extends Component {
	public var factories: Map<String, ScaleGridFactory>;

	public var defaultFactory: ScaleGridFactory;

	public function new() {
		super("scalegrid");
		final t = h2d.Tile.fromColor(0xffffffff, 8, 8);
		this.defaultFactory = new ScaleGridFactory(t, 2, 2);
		this.factories = new Map<String, ScaleGridFactory>();
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		return make(zf.Access.xml(element), context);
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext) {
		return make(zf.Access.struct(c), context);
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Object {
		final id = conf.getString("factoryId");
		final factory = this.factories.get(id) ?? context.builder.getScaleGridFactory(id) ?? this.defaultFactory;

		function parseInt(v: Dynamic, defaultValue: Null<Int> = null): Null<Int> {
			if (v == null) return defaultValue;
			if (v is String) {
				final i = context.get(cast v);
				if (i is Int) return cast i;
			}
			return Std.parseInt(v);
		}

		final width = parseInt(conf.get("width"), 1);
		final height = parseInt(conf.get("height"), 1);

		var color: Null<Color> = null;
		final colorString = conf.getString("color", null);
		if (colorString != null) {
			color = context.getColor(colorString);
		}

		final obj = factory.make(width, height, color);
		if (conf.get("name") != null) {
			Logger.debug("[Deprecated] name is deprecated for component, use id instead");
			obj.name = conf.get("name");
		}

		final alpha = conf.getFloat("alpha");
		if (alpha != null) obj.alpha = alpha;

		return obj;
	}
}

/**
	Thu 16:34:14 12 Jun 2025
	Added getScaleGridFactory to builder.
	Still keeping factories around because that is required for CR.
	Might need to fix that for CR first.
**/
