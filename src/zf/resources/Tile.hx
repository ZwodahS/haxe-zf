package zf.resources;

/**
	Tile is a combination of Tile:h2d.Tile + color:h3d.Vector + Float scale
**/
class Tile {
	public var tile(default, null): h2d.Tile;

	var innerTile: h2d.Tile;

	public var color: h3d.Vector4;
	public var scale: Float;
	public var offset: Point2i;

	public function new(t: h2d.Tile, color: h3d.Vector4, scale: Float, offset: Point2i) {
		this.innerTile = t;
		this.color = color;
		this.scale = scale;
		this.innerTile.dx = -offset.x;
		this.innerTile.dy = -offset.y;

		this.tile = this.innerTile.clone();
		if (this.scale != 1) {
			this.tile.setSize(this.tile.width * this.scale, this.tile.height * this.scale);
		}
	}

	public function getBitmap(): h2d.Bitmap {
		var bm: h2d.Bitmap = new h2d.Bitmap(this.tile.clone());
		bm.color = this.color.clone();
		return bm;
	}

	public function copy(): Tile {
		var t = new Tile(this.innerTile.clone(), this.color, this.scale, this.offset);
		return t;
	}

	public function sub(x: Int, y: Int, w: Int, h: Int) {
		// once sub, the center will be reset to 0
		return new Tile(this.innerTile.sub(x, y, w, h), this.color.clone(), this.scale, [0, 0]);
	}
}
