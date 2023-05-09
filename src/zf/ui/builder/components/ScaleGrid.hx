package zf.ui.builder.components;

/**
	@stage:stable
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
		final bm = context.getBitmap(conf);
		final factoryId = conf.getString("factoryId");
		final factory = (factoryId == null || factories.exists(factoryId) == false) ? this.defaultFactory : factories.get(factoryId);
		final width = conf.getInt("width", 1);
		final height = conf.getInt("height", 1);

		final obj = factory.make([width, height]);
		if (conf.get("name") != null) {
			Logger.debug("[Deprecated] name is deprecated for component, use id instead");
			obj.name = conf.get("name");
		}
		return obj;
	}
}
