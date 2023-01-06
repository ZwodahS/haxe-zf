package zf.ui.layout;

import zf.ds.Vector2D;

/**
	@stage:stable
**/
class FixedGridLayout extends h2d.Object {
	var gridSize: Point2i;
	var items: Vector2D<h2d.Object>;

	public function new(size: Point2i, gridSize: Point2i) {
		super();
		this.gridSize = gridSize;
		this.items = new Vector2D<h2d.Object>(size, null);
	}

	function pos(position: Point2i): Point2f {
		return [position.x * gridSize.x, position.y * gridSize.y,];
	}

	override public function addChild(obj: h2d.Object): Void {
		if (this.contains(obj)) return;
		var position = null;
		for (xy => obj in this.items.iterateYX()) {
			if (obj == null) {
				position = xy;
				break;
			}
		}
		if (position == null) return;
		super.addChild(obj);
		setChildAtPosition(obj, position);
	}

	public function setChild(obj: h2d.Object, position: Point2i): h2d.Object {
		var previousObject = this.items.get(position.x, position.y);
		if (previousObject != null) previousObject.remove();
		super.addChild(obj);
		setChildAtPosition(obj, position);
		return previousObject;
	}

	function setChildAtPosition(obj: h2d.Object, position: Point2i) {
		this.items.set(position.x, position.y, obj);
		var renderPosition = pos(position);
		obj.x = renderPosition.x;
		obj.y = renderPosition.y;
	}

	override public function removeChild(obj: h2d.Object) {
		super.removeChild(obj);
		for (xy => o in this.items.iterateYX()) {
			if (obj != o) continue;
			this.items.set(xy.x, xy.y, null);
			break;
		}
	}
}
