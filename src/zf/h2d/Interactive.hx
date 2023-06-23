package zf.h2d;

import hxd.Cursor;

/**
	@stage:stable

	Override h2d.Interactive to provide a few more functionalities.
**/
class Interactive extends h2d.Interactive {
	// set the default cursor for all interactive
	public static var defaultCursor: Cursor = Default;

	public function new(width: Float, height: Float, ?parent: h2d.Object, ?shape: h2d.col.Collider) {
		super(width, height, parent, shape);
		this.cursor = Interactive.defaultCursor;
	}

	override public function onRemove() {
		super.onRemove();
		this.dyOnRemove();
	}

	dynamic public function dyOnRemove() {}

	public function getCollisonBounds(relativeTo: h2d.Object = null, b: h2d.col.Bounds = null): h2d.col.Bounds {
		final bounds = getBounds(relativeTo, b);
		bounds.width = this.width;
		bounds.height = this.height;
		return bounds;
	}
}
