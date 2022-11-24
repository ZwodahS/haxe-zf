package zf.debug;

using zf.h2d.ObjectExtensions;

/**
	Draw bounding boxes around Interactive.

	Limitation: unable to deal with rotated entity at the moment.
	Limitation: only draw h2d.Interactive without shapes or polygon shapes.
**/
class DebugDraw {
	public var shape_outline_width: Float = 1;

	public var parent: h2d.Object;
	public var canvas: h2d.Graphics;

	public function new(parent: h2d.Object) {
		this.parent = parent;
		this.canvas = new h2d.Graphics(parent);
	}

	public inline function draw_rect(min_x: Float, min_y: Float, width: Float, height: Float, color: Int,
			?stroke: Int, alpha: Float = 1.) {
		canvas.beginFill(color, alpha);
		stroke != null ? canvas.lineStyle(shape_outline_width, stroke, 1) : canvas.lineStyle();
		canvas.drawRect(min_x, min_y, width, height);
		canvas.endFill();
	}

	public function draw_polygon(count: Int, vertices: Array<h2d.col.Point>, color: Int, ?stroke: Int,
			alpha: Float = 1, offsetX: Float = .0, offsetY: Float = .0) {
		if (count < 2) return;
		canvas.beginFill(color, alpha);
		stroke != null ? canvas.lineStyle(shape_outline_width, stroke, 1) : canvas.lineStyle();
		canvas.moveTo(vertices[count - 1].x + offsetX, vertices[count - 1].y + offsetY);
		for (i in 0...count) canvas.lineTo(vertices[i].x + offsetX, vertices[i].y + offsetY);
	}

	public function draw(parent: h2d.Object) {
		this.canvas.clear();
		this.drawObject(parent);
	}

	function drawObject(object: h2d.Object) {
		if (object.isReallyVisible() == false) return;

		final bounds = object.getBounds();
		if (Std.isOfType(object, h2d.Interactive)) {
			final i: h2d.Interactive = cast object;
			if (i.shape != null) {
				if (Std.isOfType(i.shape, h2d.col.PolygonCollider)) {
					final shape: h2d.col.PolygonCollider = cast i.shape;
					for (polygon in shape.polygons) {
						draw_polygon(polygon.length, polygon, 0xffff0000, 0xffff0000, 0, bounds.xMin, bounds.yMin);
					}
				}
			} else {
				draw_rect(bounds.xMin, bounds.yMin, i.width, i.height, 0xffff0000, 0xffff0000, 0);
			}
		} else {
			for (o in object) {
				drawObject(o);
			}
		}
	}
}
