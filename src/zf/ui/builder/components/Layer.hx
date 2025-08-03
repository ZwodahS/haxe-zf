package zf.ui.builder.components;

/**
	Create a empty h2d.Layers
**/
class Layer extends zf.ui.builder.Component {
	public function new() {
		super("layer-empty");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final component = new h2d.Layers();
		for (child in element.elements()) {
			final c = context.makeObjectFromXMLElement(child);
			component.addChild(c);
		}
		return component;
	}
}
