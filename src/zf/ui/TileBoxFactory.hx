package zf.ui;

import zf.Assets;

class TileBoxFactory {
	public static final Top = 1;
	public static final Right = 2;
	public static final Bottom = 4;
	public static final Left = 8;

	var assets: Asset2D;
	var parentTile: h2d.Tile;
	var tileSize: Point2i;

	public function new(tile: h2d.Tile, assets: Asset2D, tileSize: Point2i) {
		this.parentTile = tile;
		this.assets = assets;
		this.tileSize = tileSize;
	}

	public function make(boxSize: Point2i): h2d.Object {
		if (boxSize.x <= tileSize.x || boxSize.y <= tileSize.y) {
			return assets.getBitmap(15);
		}
		// check how many "box" we need
		var obj = new h2d.SpriteBatch(parentTile, null);
		var needX = Std.int(Math.ceil(boxSize.x / this.tileSize.x));
		var needY = Std.int(Math.ceil(boxSize.y / this.tileSize.y));
		if (needX <= 2 && needY <= 2) return obj;

		inline function getImagePos(x: Int, y: Int): Int {
			var ind = 0;
			if (x == 0) {
				ind |= Left;
			} else if (x == needX - 1) {
				ind |= Right;
			}
			if (y == 0) {
				ind |= Top;
			} else if (y == needY - 1) {
				ind |= Bottom;
			}
			return ind;
		}

		inline function xPos(x: Int): Int {
			if (x != needX - 1) return x * this.tileSize.x;
			return boxSize.x - this.tileSize.x;
		}

		inline function yPos(y: Int): Int {
			if (y != needY - 1) return y * this.tileSize.y;
			return boxSize.y - this.tileSize.y;
		}
		for (y in 0...needY) {
			for (x in 0...needX) {
				var imagePos = getImagePos(x, y);
				var b = obj.alloc(this.assets.getTile(imagePos));
				b.x = xPos(x);
				b.y = yPos(y);
			}
		}
		return obj;
	}
}
