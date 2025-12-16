package zf.ui.layout;

using zf.h2d.ObjectExtensions;

/**
	GridFlowLayout

	Provide a dynamic sized grid layout in one direction.

	FixedGridLayout requires both width and height to be specified at once.
	GridFlowLayout only requires one of them to be specified.

	This is also very similar to h2d.Flow, except that the size of the grid is fixed.
**/
enum LayoutType {
	Horizontal;
	Vertical;
}

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class GridFlowLayout extends zf.h2d.Container implements Disposable {
	/**
		Max number of items.
		If Horizontal, the maxItems refers to the number of items in each row.
		If Vertical, the maxItems refers to the number of items in each column.
	**/
	@:dispose public var maxItems: Int = 0;

	/**
		The layout type, cannot be changed after initialisation.
	**/
	@:dispose public var layout(default, null): LayoutType = Horizontal;

	/**
		Width of each cell
	**/
	@:dispose public var cellWidth(default, set): Float = 0;

	public function set_cellWidth(v: Float): Float {
		this.cellWidth = v;
		realignItems();
		return this.cellWidth;
	}

	/**
		Height of each cell
	**/
	@:dispose public var cellHeight(default, set): Float = 0;

	public function set_cellHeight(v: Float): Float {
		this.cellHeight = v;
		realignItems();
		return this.cellHeight;
	}

	/**
		SpacingX between each cell
	**/
	@:dispose public var spacingX(default, set): Float = 0;

	public function set_spacingX(v: Float): Float {
		this.spacingX = v;
		realignItems();
		return this.spacingX;
	}

	/**
		SpacingY between each cell
	**/
	@:dispose public var spacingY(default, set): Float = 0;

	public function set_spacingY(v: Float): Float {
		this.spacingY = v;
		realignItems();
		return this.spacingY;
	}

	/**
		Horizontal Alignment within each cell
	**/
	@:dispose public var horizontalAlignment(default, set): HorizontalAlignment = Center;

	public function set_horizontalAlignment(v: HorizontalAlignment): HorizontalAlignment {
		this.horizontalAlignment = v;
		realignItems();
		return this.horizontalAlignment;
	}

	/**
		Vertical Alignment within each cell
	**/
	@:dispose public var verticalAlignment: VerticalAlignment = Center;

	public function set_verticalAlignment(v: VerticalAlignment): VerticalAlignment {
		this.verticalAlignment = v;
		realignItems();
		return this.verticalAlignment;
	}

	final items: Array<h2d.Object>;

	public var sizeX(get, never): Int;
	inline public function get_sizeX(): Int {
		switch (this.layout) {
			case Horizontal:
				return this.items.length < this.maxItems ? this.items.length : this.maxItems;
			case Vertical:
				return Math.ceil(this.items.length * 1.0 / this.maxItems);
		}
	}

	public var sizeY(get, never): Int;
	inline public function get_sizeY(): Int {
		switch (this.layout) {
			case Horizontal:
				return Math.ceil(this.items.length * 1.0 / this.maxItems);
			case Vertical:
				return this.items.length < this.maxItems ? this.items.length : this.maxItems;
		}
	}

	function new() {
		super();
		this.items = [];
	}

	public static function alloc(layout: LayoutType): GridFlowLayout {
		final object = GridFlowLayout.__alloc__();

		object.layout = layout;

		return object;
	}

	public function dispose() {
		this.removeChildren();
		for (i in this.items) {
			if (i is Disposable) cast(i, Disposable).dispose();
		}
		this.items.clear();
	}

	override public function addChild(obj: h2d.Object): Void {
		if (this.contains(obj)) return;
		if (this.items.indexOf(obj) != -1) return;
		super.addChild(obj);
		this.items.push(obj);
		realignItems(obj);
	}

	override public function removeChild(obj: h2d.Object) {
		super.removeChild(obj);
		this.items.remove(obj);
		realignItems();
	}

	public function getItemIndex(x: Int, y: Int, wrap: Bool = false): Null<Int> {
		if (y < 0 || x < 0) return null;
		switch (this.layout) {
			case Horizontal:
				if (x >= this.maxItems) return null;
				final i = (y * this.maxItems) + x;
				return i >= this.items.length ? null : i;
			case Vertical:
				if (y >= this.maxItems) return null;
				final i = (x * this.maxItems) + y;
				return i >= this.items.length ? null : i;
		}
		return null;
	}

	public function getItemPosition(index: Int): Point2i {
		if (index < 0 || index >= this.items.length) return null;
		switch (this.layout) {
			case Horizontal:
				return Point2i.rowColumn(this.maxItems, index);
			case Vertical:
				return Point2i.columnRow(this.maxItems, index);
		}
	}

	var bounds: h2d.col.Bounds;

	function alignObject(object: h2d.Object, index: Int) {
		final position: Point2i = switch (this.layout) {
			case Horizontal: Point2i.rowColumn(this.maxItems, index);
			case Vertical: Point2i.columnRow(this.maxItems, index);
		}

		final xSetMode = switch (this.horizontalAlignment) {
			case Left: AnchorLeft;
			case Center: AnchorCenter;
			case Right: AnchorRight;
			default: AnchorLeft;
		}
		final ySetMode = switch (this.verticalAlignment) {
			case Top: AnchorTop;
			case Center: AnchorCenter;
			case Bottom: AnchorBottom;
			default: AnchorTop;
		}

		final bounds = this.bounds ?? new h2d.col.Bounds();
		this.bounds = bounds;
		bounds.x = position.x * (this.cellWidth + this.spacingX);
		bounds.y = position.y * (this.cellHeight + this.spacingY);
		bounds.width = this.cellWidth;
		bounds.height = this.cellHeight;

		object.setXInBound(bounds, xSetMode);
		object.setYInBound(bounds, ySetMode);

		position.dispose();
	}

	function realignItems(item: h2d.Object = null) {
		if (this.items.length == 0) return;
		if (item != null) {
			final index = this.items.indexOf(item);
			alignObject(item, index);
		}
		for (index => item in this.items) {
			if (item == null) continue;
			alignObject(item, index);
		}
	}
}
