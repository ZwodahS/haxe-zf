package zf.ui;

import zf.h2d.ScaleGrid;
import zf.Assets;

class ScaleGridFactory {
	var borderLeft: Int;
	var borderRight: Int;
	var borderTop: Int;
	var borderBottom: Int;
	var tile: h2d.Tile;

	public var tiling: Bool = false;

	public var minWidth(get, never): Int;
	public var minHeight(get, never): Int;

	public function new(tile: h2d.Tile, borderL: Int, borderT: Int, ?borderR: Int, ?borderB: Int) {
		this.borderLeft = borderL;
		this.borderRight = (borderR != null) ? borderR : borderL;
		this.borderTop = borderT;
		this.borderBottom = (borderB != null) ? borderB : borderT;
		this.tile = tile;
	}

	public function make(boxSize: Point2i): ScaleGrid {
		var obj = new ScaleGrid(this.tile, this.borderLeft, this.borderTop, this.borderRight, this.borderBottom);
		obj.width = boxSize.x;
		obj.height = boxSize.y;
		obj.tiling = this.tiling;
		return obj;
	}

	public function get_minWidth(): Int {
		return this.borderLeft + this.borderRight + 1;
	}

	public function get_minHeight(): Int {
		return this.borderTop + this.borderBottom + 1;
	}
}
