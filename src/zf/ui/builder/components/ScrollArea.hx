package zf.ui.builder.components;

/**
	Create a scroll area, wrapping around a object

	# Attributes
	- factoryId=String -> context.builder.getScaleGridFactory(factoryId)
	- width=Int
	- height=Int
	- cursorColor=Color
**/
class ScrollArea extends Component {
	public var factories: Map<String, ScaleGridFactory>;

	public function new() {
		super("scroll");
		this.factories = new Map<String, ScaleGridFactory>();
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final firstElement = element.firstElement();

		final factoryId = conf.getString("factoryId");
		final cursorFactory = this.factories.get(factoryId) ?? context.builder.getScaleGridFactory(factoryId);

		var child: h2d.Object = null;
		if (firstElement != null) {
			child = context.build(firstElement)?.object;
			// Mon 14:52:27 15 Dec 2025 Not sure why this is in this block, might need to be outside.
			if (child == null) return null;
		}

		final width = conf.getInt("width", 0);
		final height = conf.getInt("height", 0);
		final color: Color = conf.getInt("cursorColor", 0xffffffff);

		final component = zf.ui.ScrollArea.make({
			object: child,
			size: [width, height],
			cursorColor: color,
			cursorFactory: cursorFactory
		});

		return {object: component};
	}
}
