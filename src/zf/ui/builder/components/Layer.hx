package zf.ui.builder.components;

class Layer extends zf.ui.builder.Component {
	public function new() {
		super("layer-empty");
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): h2d.Object {
		return make(zf.Access.struct(s), context);
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		return make(zf.Access.xml(element), context);
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Object {
		final component = new h2d.Layers();
		if (conf.getString("name") != null) component.name = conf.getString("name");
		return component;
	}
}
