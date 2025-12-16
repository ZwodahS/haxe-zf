package zf.ui.builder.components;

import zf.nav.NavigationNode;
import zf.nav.StaticNavigationNode;
import zf.nav.StaticNavigationGroup;

/**
	Create a h2d.Flow with layout = horizontal

	# Attributes (Flow)
	These are mapped to various attribute in h2d.Flow

	- align=["top"|"bottom"|"middle"] -> flow.verticalAlign
	- spacing=Int -> flow.horizontalSpacing
	- maxWidth=Int -> flow.maxWidth, will also set flow.multiline to true
		- spacingY -> if maxWidth is set, spacingY is available to set flow.verticalSpacing
			if not provided, spacing will be used.
**/
class HorizontalFlowLayout extends Component {
	public function new() {
		super("layout-hflow");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);

		final flow = new h2d.Flow();
		flow.layout = Horizontal;
		{ // Handle Alignment
			flow.verticalAlign = switch (conf.getString("align")) {
				case "top": Top;
				case "bottom": Bottom;
				case "middle": Middle;
				default: Middle;
			}
		}

		{ // Get MaxWidth & Spacing
			final spacing = conf.getInt("spacing");
			if (spacing != null) flow.horizontalSpacing = spacing;
			final maxWidth = conf.getInt("maxWidth");
			if (maxWidth != null) {
				flow.maxWidth = maxWidth;
				flow.multiline = true;
				final spacingY = conf.getInt("spacingY");
				if (spacingY != null) {
					flow.verticalSpacing = spacingY;
				} else if (spacing != null) {
					flow.verticalSpacing = spacing;
				}
			}
		}

		var objects: Array<ComponentObject> = [];

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final object = newContext.build(e);
			if (object == null) return;
			objects.push(object);

			flow.addChild(object.object);
			return;
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
			final childrenKey: String = conf.getString("children");
			final loopData: Array<Dynamic> = if (loopKey == null) null else context.data.get(loopKey);
			final children: Array<Dynamic> = if (childrenKey == null) null else context.data.get(childrenKey);
			if (loopData != null) {
				for (data in loopData) {
					final ctx = context.expandTemplateContext(data);
					for (e in element.elements()) addElement(e, ctx);
				}
			} else if (children != null) {
				// if children key is not null, we will assume that each element inside is a h2d.Object
				for (c in children) {
					if (c is h2d.Object) flow.addChild(cast(c, h2d.Object));
				}
			} else {
				for (e in element.elements()) addElement(e, context);
			}
		}

		var navNode: StaticNavigationNode = null;
		if (element.get("nav") == "auto") { // Build Navigation Node
			final wrap = element.get("navWrap") == "true";
			final group = StaticNavigationGroup.alloc();
			group.name = 'HorizontalFlowLayout: ${element.get("id")}';
			navNode = group;

			final nodes = [];
			for (o in objects) {
				// only add those that have nav
				if (o.navNode == null) continue;
				nodes.push(o);
			}
			for (i in 0...nodes.length) {
				// link up each node horizontally
				final n = nodes[i];
				final prev = i == 0 ? null : nodes[i - 1].navNode;
				final next = i == nodes.length - 1 ? null : nodes[i + 1].navNode;
				n.navNode.left = prev;
				n.navNode.right = next;
				group.add(n.navNode);
			}

			if (wrap == true) {
				final first = nodes[0];
				final last = nodes.item(-1);
				first.navNode.left = last.navNode;
				last.navNode.right = first.navNode;
			}

			if (nodes.length > 0) {
				group.fromLeft = nodes.item(0).navNode;
				group.fromRight = nodes.item(-1).navNode;
				group.fromTop = nodes.item(0).navNode;
				group.fromBottom = nodes.item(0).navNode;
			}
		}

		return {object: flow, navNode: navNode};
	}
}
