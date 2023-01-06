package zf;

import zf.Logger;

/**
	@stage:stable
**/
class AssetsMap {
	public var map: Map<String, Asset2D>;

	public function new(map: Map<String, Asset2D> = null) {
		if (map == null) map = new Map<String, Asset2D>();
		this.map = map;
	}

	public function get(s: String): Asset2D {
		var a = this.map[s];
		if (a == null) {
#if debug
			Logger.debug('Assets ${s} not loaded');
#end
		}
		return a;
	}

	public function set(s: String, a: Asset2D): Asset2D {
		var prev = this.map[s];
		if (prev != null) {
			Logger.info('Duplicated Assets : ${s}. ${prev.spritesheet.filename} -> ${a.spritesheet.filename}',
				"Assets");
		}
		this.map[s] = a;
		return a;
	}

	public function add(asset: Asset2D): Asset2D {
		return this.set(asset.id, asset);
	}

	public function iterator() {
		return map.iterator();
	}

	public function keyValueIterator() {
		return map.keyValueIterator();
	}
}

@:structInit class LoadedSpritesheet {
	public var filename: String;
	public var tile: h2d.Tile;
	public var assets: AssetsMap;

	public function new(filename: String, tile: h2d.Tile, assets: Map<String, Asset2D>) {
		this.filename = filename;
		this.tile = tile;
		this.assets = new AssetsMap(assets);
	}
}

/**
	Tile is a combination of Tile:h2d.Tile + color:h3d.Vector + Float scale
**/
class Tile {
	public var tile(default, null): h2d.Tile;

	var innerTile: h2d.Tile;

	public var color: h3d.Vector;
	public var scale: Float;
	public var offset: Point2i;

	public function new(t: h2d.Tile, color: h3d.Vector, scale: Float, offset: Point2i) {
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

/**
	Asset2D defines a 2D graphical asset.
**/
class Asset2D {
	public var id: String;
	public var spritesheet(default, null): LoadedSpritesheet;
	public var tiles(default, null): Array<Tile>;
	public var count(get, null): Int;

	public function get_count(): Int {
		return this.tiles.length;
	}

	public function new(id: String, ss: LoadedSpritesheet, tiles: Array<Tile>) {
		this.id = id;
		this.spritesheet = ss;
		this.tiles = tiles;
	}

	public function getBitmap(pos: Int = 0): h2d.Bitmap {
		if (pos < 0 || pos >= this.tiles.length) pos = 0;
		return this.tiles[pos].getBitmap();
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

	public function createAnim(speed: Float = 1.0, sort: (h2d.Tile, h2d.Tile) -> Int = null, start: Int = 0,
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

	public function getAnim(): h2d.Anim {
		return this.createAnim();
	}
}

typedef AseSpritesheetConfig = {
	frames: Array<{
		filename: String,
		frame: {
			x: Int,
			y: Int,
			w: Int,
			h: Int
		},
		rotated: Bool,
		trimmed: Bool,
		spriteSourceSize: {
			x: Int,
			y: Int,
			w: Int,
			h: Int
		},
		?center: {x: Int, y: Int},
		sourceSize: {w: Int, h: Int},
		duration: Int,
	}>,
	meta: {
		image: String, frameTags: Array<{
			name: String,
			from: Int,
			to: Int,
			direction: String,
			?scale: Null<Int>,
		}>,
	}
}

class Assets {
	public static function loadAseSpritesheetConfig(filename: String): LoadedSpritesheet {
		var jsonText = hxd.Res.load(filename).toText();
		var parsed: AseSpritesheetConfig = haxe.Json.parse(jsonText);

		var data = new Map<String, Asset2D>();
		var directory = haxe.io.Path.directory(filename);
		var image = hxd.Res.load(haxe.io.Path.join([directory, parsed.meta.image])).toTile();

		final ss = new LoadedSpritesheet(filename, image, data);

		// for each frameTags, we export
		for (frame in parsed.meta.frameTags) {
			var tiles: Array<Tile> = [];
			var scale = 1;
			if (frame.scale != null) scale = frame.scale;
			for (i in frame.from...frame.to + 1) {
				var pf = parsed.frames[i];
				var f = pf.frame;
				var offset: Point2i = null;
				if (pf.center != null) {
					offset = [pf.center.x, pf.center.y];
				} else {
					offset = [0, 0];
				}
				var t = new Tile(image.sub(f.x, f.y, f.w, f.h), new h3d.Vector(1, 1, 1, 1), scale, offset);
				tiles.push(t);
			}
			data[frame.name] = new Asset2D(frame.name, ss, tiles);
		}
		return ss;
	}
}
/**
	Fri 00:45:58 14 May 2021
	The old code is moved into zf.deprecated, only the aseprite loading is kept.
**/
