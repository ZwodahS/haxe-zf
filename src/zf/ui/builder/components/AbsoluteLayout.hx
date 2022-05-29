package zf.ui.builder.components;

class AbsoluteLayout extends Component {
	public function new() {
		super("layout-absolute");
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
}
