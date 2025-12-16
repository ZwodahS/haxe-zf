package zf.ui.builder.components;

import zf.h2d.Interactive;
import zf.nav.StaticNavigationNode;
import zf.ui.builder.UINavigationNode;

typedef ObjectConf = {
	public var object: h2d.Object;
}

/**
	Display a object from the context

	# Attributes
	- object=String
**/
class Object extends Component {
	public function new() {
		super("object");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final objectKey = conf.getString("object");

		final id = element.get("id") ?? context.get("id");

		var object: h2d.Object = null;
		try {
			object = cast context.data.get(objectKey);
		} catch (e) {
			return null;
		}

		var navNode: StaticNavigationNode = null;
		if (element.get("nav") == "auto") { // Build Navigation Node
			final navOnEnter: (Xml, h2d.Object,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnEnter"));
			final navOnExit: (Xml, h2d.Object,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnExit"));
			final navOnActivate: (Xml, h2d.Object,
				BuilderContext) -> (Void->Void) = cast context.get(element.get("navOnActivate"));

			// @formatter:off
			navNode = UINavigationNode.alloc(
				navOnEnter == null ? null : navOnEnter(element, object, context),
				navOnExit == null ? null : navOnExit(element, object, context),
				navOnActivate == null ? null : navOnActivate(element, object, context)
			);

			navNode.name = 'Object NavNode: ${id}';
		}

		if (element.get("onClick") != null) {
			// note that the bound for this is fixed
			final onClick: (Xml, h2d.Object, BuilderContext) -> (hxd.Event->Void) = context.get(element.get("onClick"));
			if (onClick != null) {
				final size = object.getSize();
				final interactive = new Interactive(size.width, size.height, object);
				interactive.propagateEvents = true;
				interactive.onPush = onClick(element, object, context);
				object.addChild(interactive);
			}
		}

		return {object: object, navNode: navNode};
	}
}
