package zf.ui.builder.components;

import zf.nav.NavigationNode;
import zf.nav.StaticNavigationNode;
import zf.nav.StaticNavigationGroup;

/**
	Create a h2d.Flow with layout = vertical

	# Attributes (Flow)
	These are mapped to various attributes in h2d.Flow

	- align=["left"(default),"middle","right"] -> flow.horizontalAlign
	- spacing=Int -> flow.verticalSpacing
	- maxWidth=Int -> flow.maxWidth

	These are non-mapped keys
	- itemsKey=String
		If this is provided, then the items will be taken from BuilderContext.
		Each item should be a h2d.Object
	- loopData=String
		if provided, each children will be looped against each item in loopData,
		i.e. the number of actual children in flow will be children.length X loopData.length
		loopData is a String and the actual data is taken from Context.

	# Attributes (Children)
	- flowAlign=["center","left","right"] - override flow.Properties.horizontalAlign
**/
class VerticalFlowLayout extends Component {
	public function new() {
		super("layout-vflow");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);

		final flow = new h2d.Flow();
		flow.layout = Vertical;
		{ // Handle Alignment
			flow.horizontalAlign = switch (conf.getString("align")) {
				case "left": Left;
				case "right": Right;
				case "middle": Middle;
				default: Left;
			}
		}

		{ // Get Spacing
			final spacing = conf.getInt("spacing");
			if (spacing != null) flow.verticalSpacing = spacing;
		}

		{ // Get Max Width
			final maxWidth = conf.getInt("maxWidth");
			if (maxWidth != null) flow.maxWidth = maxWidth;
		}

		var objects: Array<ComponentObject> = [];

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final object = newContext.build(e);
			if (object == null) return null;
			objects.push(object);

			flow.addChild(object.object);
			// modify the position of the child
			final conf = zf.Access.xml(e);

			final overrideAlign = e.get("flowAlign");
			if (overrideAlign != null) {
				final prop = flow.getProperties(object.object);
				prop.horizontalAlign = switch (overrideAlign) {
					case "center": Middle;
					case "left": Left;
					case "right": Right;
					default: null;
				}
			}

			return object;
		}

		{ // Handle itemsKey
			final itemsKey = conf.get("itemsKey");
			if (itemsKey != null && context.data.exists(itemsKey)) {
				try {
					final arr: Array<Dynamic> = cast context.data.get(itemsKey);
					for (item in arr) {
						final obj: h2d.Object = cast item;
						if (obj != null) flow.addChild(item);
					}
				} catch (e) {
					Logger.exception(e);
				}
			}
		}

		{ // Handle loopData
			final loopKey: String = conf.getString("loopData");
			final loopData: Array<Dynamic> = if (loopKey == null) null else context.data.get(loopKey);
			if (loopData != null) {
				for (data in loopData) {
					final ctx = context.expandTemplateContext(data);
					for (e in element.elements()) addElement(e, ctx);
				}
			} else {
				for (e in element.elements()) addElement(e, context);
			}
		}

		var navNode: StaticNavigationNode = null;
		if (element.get("nav") == "auto") { // Build Navigation Node
			final wrap = element.get("navWrap") == "true";
			final group = StaticNavigationGroup.alloc();
			group.name = 'VerticalFlowLayout: ${element.get("id")}';
			navNode = group;

			final nodes = [];
			for (o in objects) {
				// only add those that have nav
				if (o.navNode == null) continue;
				nodes.push(o);
			}
			for (i in 0...nodes.length) {
				// link up each node vertically
				final n = nodes[i];
				final prev = i == 0 ? null : nodes[i - 1].navNode;
				final next = i == nodes.length - 1 ? null : nodes[i + 1].navNode;
				n.navNode.up = prev;
				n.navNode.down = next;
				group.add(n.navNode);
			}

			if (wrap == true) {
				final first = nodes[0];
				final last = nodes.item(-1);
				first.navNode.up = last.navNode;
				last.navNode.down = first.navNode;
			}

			if (nodes.length > 0) {
				group.fromLeft = nodes.item(0).navNode;
				group.fromRight = nodes.item(0).navNode;
				group.fromTop = nodes.item(0).navNode;
				group.fromBottom = nodes.item(-1).navNode;
			}
		}

		return {object: flow, navNode: navNode};
	}
}
