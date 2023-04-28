package zf.ui.builder.components;

typedef DynamicLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var ?items: Array<ComponentConf>;
}

/**
	@stage:stable
**/
class DynamicLayout extends Component {
	public function new() {
		super("layout-dynamic");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		/**
			For object, we assume that each object will be added in order
			and the position of each of the item will be set based on the attribute
		**/
		inline function parseInt(v: Dynamic): Null<Int> {
			if (v == null) return null;
			return Std.parseInt(v);
		}
		final obj = new h2d.Object();
		for (children in element.elements()) {
			final c = context.makeObjectFromXMLElement(children);
			if (c == null) {
				final e = new ComponentException();
				e.xmlNode = children;
				throw e;
			}
			var x = parseInt(children.get("x"));
			var y = parseInt(children.get("y"));
			if (x != null) c.x = x;
			if (y != null) c.y = y;
			obj.addChild(c);
		}
		return obj;
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext): h2d.Object {
		final conf: DynamicLayoutConf = c;
		final obj = new h2d.Object();
		if (conf.items != null) {
			for (item in conf.items) {
				final c = context.makeObjectFromStruct(item);
				if (c == null) {
					final e = new ComponentException();
					e.structNode = item;
					throw e;
				}
				final compConf: DynamicAccess<Dynamic> = item.conf;
				if (compConf.get("x") != null) c.x = compConf.get("x");
				if (compConf.get("y") != null) c.y = compConf.get("y");
				obj.addChild(c);
			}
		}
		return obj;
	}
}
