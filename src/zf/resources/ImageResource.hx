package zf.resources;

/**
	@stage:stable
**/
class ImageResource {
	/**
		The id for the image
	**/
	public var id: String;

	/**
		The inner tiles
	**/
	public var tiles: Array<Tile>;

	public function new(id: String, tiles: Array<Tile>) {
		this.id = id;
		this.tiles = tiles;
	}

	public function getBitmap(pos: Int = 0, bound: Recti = null): h2d.Bitmap {
		if (pos < 0 || pos >= this.tiles.length) pos = 0;
		return this.tiles[pos].getBitmap(bound);
	}

	public function getBitmaps(start: Int = 0, end: Int = -1): Array<h2d.Bitmap> {
		if (end <= 0) end = this.tiles.length;
		if (start < 0 || start >= end) start = end - 1;
		var out = new Array<h2d.Bitmap>();
		for (i in start...end) out.push(this.tiles[i].getBitmap());
		return out;
	}

	public function getTile(pos: Int = 0): h2d.Tile {
		if (pos < 0 || pos >= this.tiles.length) pos = 0;
		return this.tiles[pos].tile.clone();
	}

	public function getTiles(start: Int = 0, end: Int = -1): Array<h2d.Tile> {
		if (end == -1) end = this.tiles.length;
		var out = new Array<h2d.Tile>();
		var ind = 0;
		for (i in start...end) out.push(this.tiles[i].tile);
		return out;
	}

	public function getAnim(speed: Float = 1.0, sort: (h2d.Tile, h2d.Tile) -> Int = null, start: Int = 0,
			end: Int = -1): h2d.Anim {
		if (end == -1) {
			end = this.tiles.length;
		}
		var frames = new Array<h2d.Tile>();
		var ind = 0;
		for (i in start...end) {
			frames.push(this.tiles[i].tile.clone());
		}
		if (sort != null) {
			frames.sort(sort);
		}

		var anim = new h2d.Anim(frames, speed);
		anim.scaleX = this.tiles[0].scale;
		anim.scaleY = this.tiles[0].scale;
		return anim;
	}
}
