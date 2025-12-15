package zf.ui.builder.components;

/**
	Create a empty h2d.Layers
**/
class Layer extends Component {
	public function new() {
		super("layer-empty");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final component = new h2d.Layers();
		for (child in element.elements()) {
			final c = context.build(child);
			component.addChild(c.object);
		}
		return {object: component};
	}
}
