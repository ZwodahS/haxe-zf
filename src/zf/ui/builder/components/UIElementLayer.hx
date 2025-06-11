package zf.ui.builder.components;

/**
	Generate a empty "object" layer, but we will use UIElement instead
**/
class UIElementLayer extends zf.ui.builder.Component {
	public function new() {
		super('layer-object');
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): h2d.Object {
		return make(zf.Access.struct(s), context);
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final obj = make(zf.Access.xml(element), context);

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final c = newContext.makeObjectFromXMLElement(e);
			if (c == null) return null;

			obj.addChild(c);
			return null;
		}

		for (e in element.elements()) addElement(e, context);

		return obj;
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Object {
		return new UIElement();
	}
}
