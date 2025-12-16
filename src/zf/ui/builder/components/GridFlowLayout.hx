package zf.ui.builder.components;

import zf.nav.NavigationNode;
import zf.nav.StaticNavigationNode;
import zf.nav.StaticNavigationGroup;

/**
	Create a GridFlowLayout
**/
/**
	class VerticalGridFlowLayout extends Component {
	public function new() {
		super("layout-vgridflow");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final component = zf.ui.layout.GridFlowLayout.alloc(Vertical);

		final conf = zf.Access.xml(element);
		return {object: component};
	}
	}
**/
class HorizontalGridFlowLayout extends Component {
	public function new() {
		super("layout-hgridflow");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final component = zf.ui.layout.GridFlowLayout.alloc(Horizontal);
		final conf = zf.Access.xml(element);

		{ // MaxItems
			final sizeId = conf.getString("sizeId");
			final size = sizeId != null ? cast(context.get(sizeId), Int) : conf.getInt("size");
			component.maxItems = size;
		}

		{ // Handle Size
			final cellWidth = conf.getInt("cellWidth", 1);
			final cellHeight = conf.getInt("cellHeight", 1);
			component.cellWidth = cellWidth;
			component.cellHeight = cellHeight;
		}

		{ // Handle Alignment
			component.horizontalAlignment = switch (conf.getString("halign")) {
				case "left": Left;
				case "right": Right;
				case "center": Center;
				default: Left;
			}
			component.verticalAlignment = switch (conf.getString("valign")) {
				case "top": Top;
				case "bottom": Bottom;
				case "center": Center;
				default: Top;
			}
		}

		final objects: Array<ComponentObject> = [];

		inline function addElement(e: Xml, newContext: BuilderContext) {
			final object = newContext.build(e);
			if (object == null) return null;
			objects.push(object);
			component.addChild(object.object);
			return object;
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
			final group = StaticNavigationGroup.alloc();
			group.name = 'GridFlowLayout: ${element.get("id")}';
			navNode = group;

			for (i in 0...objects.length) {
				final n = objects[i];
				Assert.assert(n.navNode != null);
				final pt = component.getItemPosition(i);

				{ // link right
					final rightIndex = component.getItemIndex(pt.x + 1, pt.y);
					if (rightIndex != null) {
						final right = objects[rightIndex];
						n.navNode.right = right.navNode;
					}
				}
				{ // link left
					final leftIndex = component.getItemIndex(pt.x - 1, pt.y);
					if (leftIndex != null) {
						final left = objects[leftIndex];
						n.navNode.left = left.navNode;
					}
				}
				{ // link up
					final upIndex = component.getItemIndex(pt.x, pt.y - 1);
					if (upIndex != null) {
						final up = objects[upIndex];
						n.navNode.up = up.navNode;
					}
				}
				{ // link down
					final downIndex = component.getItemIndex(pt.x, pt.y + 1);
					if (downIndex != null) {
						final down = objects[downIndex];
						n.navNode.down = down.navNode;
					}
				}

				pt.dispose();
				group.add(n.navNode);
			}
			if (objects.length > 0) {
				group.fromLeft = objects.item(component.getItemIndex(0, 0)).navNode;
				group.fromRight = objects.item(component.getItemIndex(component.sizeX - 1, 0)).navNode;
				group.fromTop = objects.item(component.getItemIndex(0, 0)).navNode;
				group.fromBottom = objects.item(component.getItemIndex(0, component.sizeY - 1)).navNode;
			}
		}

		return {object: component, navNode: navNode};
	}
}
