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
		Anchor to the top center of the layout.
	**/
	AnchorTopCenter(spacingX: Int, spacingY: Int);

	/**
		Anchor to the center of the screen
	**/
	AnchorCenter(spacingX: Int, spacingY: Int);

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

	/**
		Anchor to the bottom right of the layout.
	**/
	AnchorBottomCenter(spacingX: Int, spacingY: Int);
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
class DynamicLayout extends UIElement {
	/**
		Size of the layout. Do not set directly
	**/
	var size: Point2i;

	var _repositions: Array<UIElement>;

	override public function get_width() {
		return size.x;
	}

	override public function get_height() {
		return size.y;
	}

	public function new(size: Point2i) {
		super();
		this.size = size;
		this._repositions = [];
	}

	public function resize(x: Int, y: Int) {
		this.size.set(x, y);
		for (child in this.children) {
			if (Std.isOfType(child, UIElement) == false) continue;
			cast(child, UIElement).reposition();
		}
	}

	override public function addChild(object: h2d.Object) {
		super.addChild(object);
		if (Std.isOfType(object, UIElement) == true) cast(object, UIElement).reposition();
		object.setParentContainer(this);
	}

	override public function contentChanged(object: h2d.Object) {
		super.contentChanged(object);
		if (object is UIElement) {
			if (object.parent == this) _repositions.push(cast object);
		} else if (object.parent != null && object.parent is UIElement) {
			if (object.parent.parent == this) _repositions.push(cast object.parent);
		}
	}

	override function sync(ctx: h2d.RenderContext) {
		if (this._repositions.length > 0) {
			for (o in this._repositions) o.reposition();
			this._repositions.clear();
		}
		super.sync(ctx);
	}
}
