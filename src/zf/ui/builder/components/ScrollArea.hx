package zf.ui.builder.components;

class ScrollArea extends zf.ui.builder.Component {
	public var factories: Map<String, ScaleGridFactory>;

	public function new() {
		super("scroll");
		this.factories = new Map<String, ScaleGridFactory>();
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): h2d.Object {
		final conf = zf.Access.struct(s);
		final factoryId = conf.getString("factoryId");

		var factory: ScaleGridFactory = null;

		if (factory == null && conf.get("factory") != null) {
			try {
				factory = conf.get("factory");
			} catch (e) {}
		}

		final item = conf.get("item");
		var child: h2d.Object = null;
		if (item != null) {
			child = context.makeObjectFromStruct(item);
			if (child == null) return null;
		}

		return make(conf, context, factory, child);
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		final conf = zf.Access.xml(element);
		final factoryId = conf.getString("factoryId");
		final factory = (factoryId == null || factories.exists(factoryId) == false) ? null : factories.get(factoryId);

		final firstElement = element.firstElement();
		var child: h2d.Object = null;
		if (firstElement != null) {
			child = context.makeObjectFromXMLElement(firstElement);
			if (child == null) return null;
		}

		return make(conf, context, factory, child);
	}

	function make(conf: zf.Access, context: BuilderContext, cursorFactory: zf.ui.ScaleGridFactory,
			child: h2d.Object): h2d.Object {
		final width = conf.getInt("width", 0);
		final height = conf.getInt("height", 0);
		final color: Color = conf.getInt("cursorColor", 0xffffffff);

		final component = zf.ui.ScrollArea.make({
			object: child,
			size: [width, height],
			cursorColor: color,
			cursorFactory: cursorFactory
		});
		if (conf.getString("name") != null) component.name = conf.getString("name");

		return component;
	}
}
