package zf.ui.layout;

/**
	The position. Build as we need it
	- CenterLeft, CenterTop, CenterRight, CenterBottom
**/
enum DynamicLayoutPosition {
	/**
		Aboslute position
	**/
	Absolute(x: Float, y: Float);

	/**
		Anchor to the top left of the layout, almost the same as fixed but take into account the xMin/xMax
	**/
	AnchorTopLeft(spacingX: Float, spacingY: Float);

	/**
		Anchor to the top center of the layout.
	**/
	AnchorTopCenter(spacingX: Float, spacingY: Float);

	/**
		Anchor to the left center of the screen
	**/
	AnchorCenterLeft(spacingX: Float, spacingY: Float);

	/**
		Anchor to the center of the screen
	**/
	AnchorCenterCenter(spacingX: Float, spacingY: Float);

	/**
		Anchor to the right center of the screen
	**/
	AnchorCenterRight(spacingX: Float, spacingY: Float);

	/**
		Anchor to the top right of the layout.
	**/
	AnchorTopRight(spacingX: Float, spacingY: Float);

	/**
		Anchor to the bottom left of the layout.
	**/
	AnchorBottomLeft(spacingX: Float, spacingY: Float);

	/**
		Anchor to the bottom right of the layout.
	**/
	AnchorBottomRight(spacingX: Float, spacingY: Float);

	/**
		Anchor to the bottom right of the layout.
	**/
	AnchorBottomCenter(spacingX: Float, spacingY: Float);
}

#if !macro @:build(zf.macros.ObjectPool.build()) #end
@:allow(zf.ui.layout.DynamicLayout)
class DynamicLayoutProperties implements Disposable {
	public function new() {}

	@:dispose("set") var layout: DynamicLayout = null;
	@:dispose var object: h2d.Object = null;

	/**
		The position type of the children
	**/
	@:dispose public var position(default, set): DynamicLayoutPosition = Absolute(0, 0);

	public function set_position(v: DynamicLayoutPosition): DynamicLayoutPosition {
		this.position = v;
		if (this.layout != null && this.object != null && this.frozen != true) {
			this.layout.scheduleReposition(this.object, this);
		}
		return this.position;
	}

	public function toString() {
		return '[DynamicLayoutProperties|${this.position}]';
	}

	/**
		If true, this will not move on content changed.
	**/
	@:dispose public var frozen: Bool = false;
}

/**
	DynamicLayout allow for children to anchor to the 8 corners of the layout + Center.
	Either width and height
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class DynamicLayout extends zf.h2d.Container implements Disposable {
	/**
		The width of the DynamicLayout
	**/
	@:dispose public var width(default, set): Null<Int> = null;

	public function set_width(v: Null<Int>): Null<Int> {
		this.width = v;
		this.repositionAll = true;
		return this.width;
	}

	/**
		The height of the DynamicLayout
	**/
	@:dispose public var height(default, set): Null<Int> = null;

	public function set_height(v: Null<Int>): Null<Int> {
		this.height = v;
		this.repositionAll = true;
		return this.height;
	}

	/**
		If true, all children will be repositioned the next frame
	**/
	@:dispose var repositionAll: Bool = false;

	/**
		The children to reposition in this frame
	**/
	@:dispose var repositions: Array<h2d.Object> = null;

	/**
		The DynamicLayoutProperties for each children
	**/
	@:dispose("all") var properties: Array<DynamicLayoutProperties>;

	/**
		Insert a child object at the specified position of the children list.
	**/
	override function addChildAt(obj: h2d.Object, pos: Int) {
		// get the property of the obj first since addChildAt might change the position
		var prop = getProperties(obj);
		super.addChildAt(obj, pos);

		if (prop != null) {
			// if prop is not null, it means that this obj is already on this layout, so we remove it.
			this.properties.remove(prop);
		} else {
			// create the prop if null
			prop = DynamicLayoutProperties.alloc();
			prop.layout = this;
			prop.object = obj;
		}

		this.properties.insert(pos, prop);
		scheduleReposition(obj);
	}

	/**
		Insert a child object to a specific position.

		@param object the object to add
		@param position the position to add it to
		@param frozen if the position is frozen and does not reposition when it changes.
	**/
	public function addChildTo(obj: h2d.Object, position: DynamicLayoutPosition = null, frozen: Bool = false) {
		if (position == null) position = Absolute(0, 0);
		this.addChild(obj);
		final prop = getProperties(obj);
		prop.position = position;
		prop.frozen = frozen;
		// already scheduled via addChildAt so we don't have to handle that.
	}

	function repositionChild(obj: h2d.Object) {
		final prop = getProperties(obj);
		final bounds = obj.getBounds(obj);

#if debug
		/**
			Fri 13:10:56 01 Aug 2025
			I think anchoring right and bottom without width/height has some use cases.
			I want to observe what I want the behavior to be, so instead of blocking it, we will warn first.
		**/
		if (this.width == null && this.height == null) {
			switch (prop.position) {
				case Absolute(_, _):
				default:
					Logger.debug("[Warning] width and height is null & positioning is not Absolute", "[DynamicLayout]");
			}
		} else if (this.width == null) {
			// if width is null, anchoring right is weird
			switch (prop.position) {
				case AnchorTopRight(_, _), AnchorCenterRight(_, _), AnchorBottomRight(_, _):
					Logger.debug("[Warning] width is null, anchoring right will have unexpected behavior.",
						"[DynamicLayout]");
				default:
			}
		} else if (this.height == null) {
			// if height is null, anchoring bottom is weird
			switch (prop.position) {
				case AnchorBottomLeft(_, _), AnchorBottomCenter(_, _), AnchorBottomRight(_, _):
					Logger.debug("[Warning] height is null, anchoring bottom will have unexpected behavior.",
						"[DynamicLayout]");
				default:
			}
		}
#end
		switch (prop.position) {
			case Absolute(x, y):
				obj.x = x;
				obj.y = y;
			case AnchorTopLeft(spacingX, spacingY):
				obj.x = 0 + spacingX - bounds.xMin;
				obj.y = 0 + spacingY - bounds.yMin;
			case AnchorTopCenter(spacingX, spacingY):
				obj.x = ((this.width - bounds.width) / 2) + spacingX - bounds.xMin;
				obj.y = 0 + spacingY - bounds.yMin;
			case AnchorTopRight(spacingX, spacingY):
				obj.x = this.width - bounds.width - bounds.xMin - spacingX;
				obj.y = spacingY - bounds.yMin;
			case AnchorCenterLeft(spacingX, spacingY):
				obj.x = 0 + spacingX - bounds.xMin;
				obj.y = ((this.height - bounds.height) / 2) + spacingY - bounds.yMin;
			case AnchorCenterCenter(spacingX, spacingY):
				obj.x = ((this.width - bounds.width) / 2) + spacingX - bounds.xMin;
				obj.y = ((this.height - bounds.height) / 2) + spacingY - bounds.yMin;
			case AnchorCenterRight(spacingX, spacingY):
				obj.x = this.width - bounds.width - bounds.xMin - spacingX;
				obj.y = ((this.height - bounds.height) / 2) + spacingY - bounds.yMin;
			case AnchorBottomLeft(spacingX, spacingY):
				obj.x = spacingX - bounds.xMin;
				obj.y = this.height - bounds.height - bounds.yMin - spacingY;
			case AnchorBottomCenter(spacingX, spacingY):
				obj.x = ((this.width - bounds.width) / 2) + spacingX - bounds.xMin;
				obj.y = this.height - bounds.height - bounds.yMin - spacingY;
			case AnchorBottomRight(spacingX, spacingY):
				obj.x = this.width - bounds.width - bounds.xMin - spacingX;
				obj.y = this.height - bounds.height - bounds.yMin - spacingY;
		}
	}

	override public function removeChild(obj: h2d.Object) {
		final index = getChildIndex(obj);
		super.removeChild(obj);
		if (index >= 0) {
			final prop = this.properties[index];
			properties.splice(index, 1);
			prop.dispose();
		}
	}

	override function getBoundsRec(relativeTo: h2d.Object, out: h2d.col.Bounds, forSize: Bool) {
		reposition();
		if (forSize == true) {
			if (this.width == null || this.height == null) {
				super.getBoundsRec(relativeTo, out, forSize);
				if (this.width != null) out.width = this.width;
				if (this.height != null) out.height = this.height;
			} else {
				addBounds(relativeTo, out, 0, 0, this.width, this.height);
			}
		} else {
			super.getBoundsRec(relativeTo, out, forSize);
		}
	}

	/**
		Schedule an child object to be repositioned
	**/
	public function scheduleReposition(obj: h2d.Object, prop: DynamicLayoutProperties = null) {
		if (obj.parent != this || this.repositions.contains(obj) == true) return;
		if (prop == null) prop = this.getProperties(obj);
		if (prop.frozen == true) return;
		this.repositions.push(obj);
	}

	/**
		Get the DynamicLayoutProperties of the object
	**/
	public function getProperties(obj: h2d.Object) {
		final index = this.getChildIndex(obj);
		if (index == -1) return null;
		return this.properties[index];
	}

	override public function contentChanged(object: h2d.Object) {
		while (object.parent != this) {
			object = object.parent;
		}
		scheduleReposition(object);
		onContentChanged();
	}

	override function sync(ctx: h2d.RenderContext) {
		if (this.interactive != null) {
			// FIXME: This might be a problem when one of them is null
			if (this.width != null && this.height != null) {
				this.interactive.width = this.width;
				this.interactive.height = this.height;
			}
		}
		reposition();
		super.sync(ctx);
	}

	function reposition() {
		if (this.repositionAll == true) {
			for (obj in this.children) this.scheduleReposition(obj);
			this.repositionAll = false;
		}
		if (this.repositions.length > 0) {
			for (obj in this.repositions) this.repositionChild(obj);
			this.repositions.clear();
		}
	}

	public function dispose() {
		final toDispose: Array<Disposable> = [];
		for (child in this.children) {
			if (child is Disposable) toDispose.push(cast child);
		}
		removeChildren();
		for (d in toDispose) d.dispose();
	}

	public static function alloc(width: Null<Int> = null, height: Null<Int> = null) {
		final layout = __alloc__();

		layout.repositions = [];
		layout.properties = [];
		layout.width = width;
		layout.height = height;

		return layout;
	}
}
/**
	Sat 16:30:48 02 Aug 2025
	Refactored DynamicLayout to store the properties instead.
**/
