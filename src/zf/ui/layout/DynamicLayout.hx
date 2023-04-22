package zf.ui.layout;

/**
	The position. Build as we need it

	@todo
	- CenterLeft, CenterTop, CenterRight, CenterBottom
**/
enum DynamicPosition {
	/**
		Fixed position, just set the x/y
	**/
	Fixed(x: Int, y: Int);

	/**
		Anchor to the top left of the layout, almost the same as fixed but take into account the xMin/xMax
	**/
	AnchorTopLeft(spacingX: Int, spacingY: Int);

	/**
		Anchor to the top right of the layout.
	**/
	AnchorTopRight(spacingX: Int, spacingY: Int);

	/**
		Anchor to the bottom left of the layout.
	**/
	AnchorBottomLeft(spacingX: Int, spacingY: Int);

	/**
		Anchor to the bottom right of the layout.
	**/
	AnchorBottomRight(spacingX: Int, spacingY: Int);
}

/**
	@stage:stable

	The basic idea of DynamicLayout is this.

	1. This layout will have a fixed size
	2. Each child in this layout will decide how they want to reposition themselves.
	3. For normal object, we will assume that they will be positioned based on their x,y (i.e. absolute positioning)
	4. For UIElement object (the best way to use this layout), the UIElement's reposition method will be called.
	5. If the layout is resized, all children that is a UIElement will reposition
**/
class DynamicLayout extends h2d.Object {
	/**
		Size of the layout. Do not set directly
	**/
	var size: Point2i;

	public function new(size: Point2i) {
		super();
		this.size = size;
	}

	public function resize(newSize: Point2i) {
		this.size.update(newSize);
		for (child in this.children) {
			if (Std.isOfType(child, UIElement) == false) continue;
			cast(child, UIElement).reposition();
		}
	}

	override public function addChild(object: h2d.Object) {
		super.addChild(object);
		if (Std.isOfType(object, UIElement) == true) cast(object, UIElement).reposition();
	}
}
