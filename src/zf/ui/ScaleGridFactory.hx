package zf.ui;

import zf.h2d.ScaleGrid;

/**
	@stage:stable
**/
class ScaleGridFactory {
	var borderLeft: Int;
	var borderRight: Int;
	var borderTop: Int;
	var borderBottom: Int;
	var tile: h2d.Tile;

	public var color: Null<Color>;

	public var tiling: Bool = false;

	public var minWidth(get, never): Int;
	public var minHeight(get, never): Int;

	public function new(tile: h2d.Tile, borderL: Int, borderT: Int, ?borderR: Int, ?borderB: Int,
			color: Null<Color> = null) {
		this.borderLeft = borderL;
		this.borderRight = (borderR != null) ? borderR : borderL;
		this.borderTop = borderT;
		this.borderBottom = (borderB != null) ? borderB : borderT;
		this.tile = tile;
		this.color = color;
	}

	public function make(boxSize: Point2i, color: Null<Color> = null): ScaleGrid {
		var obj = new ScaleGrid(this.tile, this.borderLeft, this.borderTop, this.borderRight, this.borderBottom);
		obj.width = boxSize.x;
		obj.height = boxSize.y;
		obj.tiling = this.tiling;
		if (color != null) {
			obj.color = h3d.Vector4.fromColor(color);
		} else if (this.color != null) {
			obj.color = h3d.Vector4.fromColor(this.color);
		}
		return obj;
	}

	public function get_minWidth(): Int {
		return this.borderLeft + this.borderRight + 1;
	}

	public function get_minHeight(): Int {
		return this.borderTop + this.borderBottom + 1;
	}
}
