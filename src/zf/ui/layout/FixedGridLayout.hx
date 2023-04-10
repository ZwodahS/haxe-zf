package zf.ui.layout;

import zf.ds.Vector2D;

/**
	@stage:stable
**/
class FixedGridLayout extends h2d.Object {
	var size: Point2i;
	var gridSize: Point2i;

	var items: Array<h2d.Object>;

	public var alignCenter(default, set): Bool = false;

	public function set_alignCenter(v: Bool = true): Bool {
		this.alignCenter = v;
		realign();
		return this.alignCenter;
	}

	public var spacing(default, set): Point2i = [0, 0];

	public function set_spacing(v: Point2i): Point2i {
		this.spacing = v;
		realign();
		return this.spacing;
	}

	public var totalSize(get, never): Point2f;

	public function get_totalSize(): Point2f {
		return [
			(this.size.x * this.gridSize.x) + ((this.size.x - 1) * (this.spacing.x)),
			(this.size.y * this.gridSize.y) + ((this.size.y - 1) * (this.spacing.y)),
		];
	}

	public function new(size: Point2i, gridSize: Point2i) {
		super();
		this.size = size;
		this.gridSize = gridSize;
		this.items = [];
	}

	function pos(index: Int): Point2f {
		final position = Point2i.rowColumn(this.size.x, index);
		if (this.alignCenter == true) {
			return [
				(position.x * (this.gridSize.x + this.spacing.x)) + (gridSize.x / 2),
				(position.y * (this.gridSize.y + this.spacing.y)) + (gridSize.y / 2),
			];
		} else {
			return [
				(position.x * (this.gridSize.x + this.spacing.x)),
				(position.y * (this.gridSize.y + this.spacing.y)),
			];
		}
	}

	override public function addChild(obj: h2d.Object): Void {
		if (this.contains(obj)) return;
		if (this.items.indexOf(obj) != -1) return;
		super.addChild(obj);
		this.items.push(obj);
		realign();
	}

	override public function removeChild(obj: h2d.Object) {
		super.removeChild(obj);
		this.items.remove(obj);
		realign();
	}

	function realign() {
		for (index in 0...(this.size.x * this.size.y)) {
			if (index >= this.items.length) break;
			final item = this.items[index];
			final position = pos(index);
			item.x = position.x;
			item.y = position.y;
		}
	}
}
