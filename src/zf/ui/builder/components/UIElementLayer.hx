package zf.ui.builder.components;

/**
	Generate a empty "object" layer, but we will use UIElement instead
**/
class UIElementLayer extends Component {
	public function new() {
		super('layer-object');
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final obj = new UIElement();

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final c = newContext.build(e)?.object;
			if (c == null) return;

			obj.addChild(c);
			return;
		}

		for (e in element.elements()) addElement(e, context);

		return {object: obj};
	}
}
