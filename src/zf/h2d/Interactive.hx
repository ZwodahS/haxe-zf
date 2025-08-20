package zf.h2d;

import hxd.Cursor;

/**
	@stage:stable

	Override h2d.Interactive to provide a few more functionalities.
**/
class Interactive extends h2d.Interactive {
	// set the default cursor for all interactive
	public static var defaultCursor: Cursor = null;

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

#if debug
	public static var EventDebugMessage: Bool = false;
#end

	override public function handleEvent(e: hxd.Event) {
		super.handleEvent(e);
#if debug
		if (Interactive.EventDebugMessage) {
			// we ignore ECheck
			switch (e.kind) {
				case ECheck:
				default:
					// @formatter:off
					Logger.debug('[${e} (Cancel: ${e.cancel})(Propagate: ${e.propagate})] in ${this.parent?.name}.${this.name}', "[Interactive]");
			}
		}
#end
	}
}
