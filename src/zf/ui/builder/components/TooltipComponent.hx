package zf.ui.builder.components;

import zf.ui.TooltipHelper;
import zf.ui.UIElement.TooltipShowConf;

/**
	Usage:
	<tooltip>
		<element>
	</tooltip>

	Or
	<layout>
		<tooltip />
	</layout>

	An additional interactive will be added to the element with propagateEvents true

	xml attribute:
	- width (float) : optional
	- height (float) : optional
	if width and height is not provided, it will be taken from the child if exists.
		if child is UIElement, will use .width and .height
		else we will use getSize() from h2d.Object

	- tooltipId
	- tooltipContextKey (the string context will be taken from context)
	- titleId
	- titleContextKey (the string context will be taken from context)

	Wed 13:55:59 18 Oct 2023
	Currently there is a limitation of tooltip on flow.
	It will not be resized properly if the flow size changed, or the size of the child class changed
**/
class TooltipComponent extends zf.ui.builder.Component {
	public function new() {
		super("tooltip");
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): h2d.Object {
		// We will not implement the non-xml version since it is quite pointless
		throw new zf.exceptions.NotImplemented();
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		function parseFloat(v: Dynamic): Null<Float> {
			try {
				final p = Std.parseFloat(v);
				if (Math.isNaN(p)) return null;
				return p;
			} catch (e) {}
			return null;
		}

		var width: Float = 0;
		var height: Float = 0;

		var tooltipHelper: TooltipHelper = null;
		var tooltipParent: h2d.Object = null;
		var tooltipShowConf: TooltipShowConf = null;
		{
			final o = context.get("tooltipHelper");
			if (o != null && Std.isOfType(o, TooltipHelper)) tooltipHelper = cast o;
			final o = context.get("tooltipBoundsParent");
			if (o != null && Std.isOfType(o, h2d.Object)) tooltipParent = cast o;
			final o = context.get("tooltipShowConf");
			try {
				tooltipShowConf = cast o;
			} catch (e) {}
		}

		// ---- figure out the size of the object first ----
		{
			final w = parseFloat(element.get("width"));
			if (w != null) width = w;

			final h = parseFloat(element.get("height"));
			if (h != null) height = h;
		}

		final childElement = element.firstElement();
		final child = if (childElement != null) context.makeObjectFromXMLElement(childElement) else null;

		if (tooltipHelper == null) return child;

		if (width == 0 || height == 0) {
			if (child != null) {
				if (Std.isOfType(child, UIElement)) {
					final e: UIElement = cast child;
					if (width == 0) width = e.width;
					if (height == 0) height = e.height;
				} else if (Std.isOfType(child, h2d.Object)) {
					final o: h2d.Object = cast child;
					final size = o.getSize();
					if (width == 0) width = size.width;
					if (height == 0) height = size.height;
				}
			}
		}

		if (width == 0 || height == 0) return null;

		// ---- figure out the tooltip ---- //
		final tooltipId = element.get("tooltipId");
		final tooltipContextKey = element.get("tooltipContextKey");
		final tooltipContext = if (tooltipContextKey != null) context.get(tooltipContextKey) else {}
		final titleId = element.get("titleId");
		final titleContextKey = element.get("titleContextKey");
		final titleContext = if (titleContextKey != null) context.get(titleContextKey) else {}

		final window = makeTextTooltipWindow(tooltipId, tooltipContext, titleId, titleContext);
		if (window == null) return null;

		// ---- Set up the interactive ---- //
		final interactive = new zf.h2d.Interactive(width, height);
		interactive.backgroundColor = 0x00000000;
		interactive.propagateEvents = true;
		final uiElement = new UIElement();
		uiElement.addChild(uiElement.interactive = interactive);
		uiElement.tooltipHelper = tooltipHelper;
		uiElement.tooltipShowConf = tooltipShowConf;
		uiElement.getTooltipBounds = () -> {
			return uiElement.getBounds(tooltipParent);
		}
		uiElement.tooltipWindow = window;

		if (child != null) {
			// If this wrap a child, add it to the child and return the child
			child.addChild(uiElement);
			return child;
		} else {
			// If doesn't wrap a child, just return the interactive
			return uiElement;
		}
	}

	// ---- Override ---- //
	dynamic public function makeTextTooltipWindow(tooltipId: String, tooltipContext: Dynamic, titleId: String,
			titleContext: Dynamic): UIElement {
		return null;
	}
}
