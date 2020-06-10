package common;

import haxe.ds.Vector;

typedef TileConf = {
    var x: Int;
    var y: Int;
    var w: Int;
    var h: Int;
    var image: h2d.Tile;
}

/**
    Tile is a combination of Tile:h2d.Tile + color:h3d.Vector
**/
class Tile {
    public var tile: h2d.Tile;
    public var color: h3d.Vector;
    public var scale: Float;

    public function new(t: h2d.Tile, color: h3d.Vector, scale: Float) {
        this.tile = t;
        this.color = color;
        this.scale = scale;
    }

    public function getBitmap(): h2d.Bitmap {
        var bm: h2d.Bitmap = new h2d.Bitmap(this.tile);
        bm.color = this.color;
        bm.scaleX = this.scale;
        bm.scaleY = this.scale;
        return bm;
    }

    public function copy(): Tile {
        var t = new Tile(this.tile, this.color, this.scale);
        return t;
    }
}

/**
    Asset2D is a single asset
    It contains a list of tile to create animation if needed.
**/
class Asset2D {
    public var key: String;
    public var tiles: Array<Tile>;

    public var count(get, null): Int;

    public function get_count(): Int {
        return this.tiles.length;
    }

    public function new(key, tiles) {
        this.key = key;
        this.tiles = tiles;
    }

    public function getBitmap(pos: Int = 0): h2d.Bitmap {
        if (pos < 0 || pos >= this.tiles.length) {
            pos = 0;
        }
        return this.tiles[pos].getBitmap();
    }

    public function getBitmaps(start: Int = 0, end: Int = -1): Vector<h2d.Bitmap> {
        if (end == -1) {
            end = this.tiles.length;
        }
        var out = new Vector<h2d.Bitmap>(end - start);
        var ind = 0;
        for (i in start...end) {
            out[ind++] = this.tiles[i].getBitmap();
        }
        return out;
    }

    public function getTiles(start: Int = 0, end: Int = -1): Array<h2d.Tile> {
        if (end == -1) {
            end = this.tiles.length;
        }
        var out = new Array<h2d.Tile>();
        var ind = 0;
        for (i in start...end) {
            out.push(this.tiles[i].tile);
        }
        return out;
    }

    public function getAnim(speed: Float, sort: (h2d.Tile, h2d.Tile) -> Int, start: Int = 0,
            end: Int = -1): h2d.Anim {
        if (end == -1) {
            end = this.tiles.length;
        }
        var frames = new Array<h2d.Tile>();
        var ind = 0;
        for (i in start...end) {
            frames.push(this.tiles[i].tile);
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

typedef Frame = {
    var img: String;
    var src: String;
    var key: String;
    var color: Array<Int>;
    var scale: Null<Float>;
}

typedef Rect = {
    var width: Int;
    var height: Int;
    var color: Array<Int>;
    var scale: Null<Float>;
}

typedef Data = {
    var rect: Rect;
    var rects: Array<Rect>;
    var frame: Frame;
    var frames: Array<Frame>;
}

/**
    Assets is the main loader and assets container.
**/
class Assets {
    var assetsMap: Map<String, Map<String, TileConf>>;

    var assets2D: Map<String, Asset2D>;

    public function new() {
        assetsMap = new Map<String, Map<String, TileConf>>();
        assets2D = new Map<String, Asset2D>();
    }

    public function getAssetsMap(filename: String): Map<String, TileConf> {
        if (this.assetsMap[filename] != null) {
            return this.assetsMap[filename];
        }

        // open the json file
        var jsonText = hxd.Res.load(filename + ".json").toText();
        var parsed = haxe.Json.parse(jsonText);

        var data = new Map<String, TileConf>();

        for (key in Reflect.fields(parsed)) {
            data[key] = Reflect.field(parsed, key);
        }

        // open the image file
        var image = hxd.Res.load(filename + ".png").toTile();
        for (k => v in data) {
            v.image = image.sub(v.x, v.y, v.w, v.h);
        }
        this.assetsMap[filename] = data;

        return data;
    }

    private function getTile(src: String, key: String): h2d.Tile {
        var map = this.getAssetsMap(src);
        if (map[key] == null) {
            return null;
        }
        return map[key].image;
    }

    inline function makeTile(frame: Frame): Tile {
        var color: h3d.Vector;
        if (frame.color != null) {
            color = new h3d.Vector(frame.color[0] / 255, frame.color[1] / 255, frame.color[2] / 255,
                frame.color[3] / 255);
        } else {
            color = new h3d.Vector(1.0, 1.0, 1.0, 1.0);
        }
        var t: h2d.Tile = null;
        if (frame.img != null) {
            t = hxd.Res.load(frame.img).toTile();
        } else {
            t = this.getTile(frame.src, frame.key);
        }

        if (t == null) {
#if debug
            trace('Unable to load assets: ${frame.key}');
#end
            return null;
        }
        return new Tile(t, color, frame.scale == null ? 1.0 : frame.scale);
    }

    public static function parseAssets(assetPath: String): Assets {
        var _assets = new Assets();
        var jsonText = hxd.Res.load(assetPath).toText();
        var parsed = haxe.Json.parse(jsonText);

        for (key in Reflect.fields(parsed)) {
            var data: Data = Reflect.field(parsed, key);
            var tiles = new Array<Tile>();

            if (data.frame != null) {
                var t = _assets.makeTile(data.frame);
                if (t != null) {
                    tiles.push(t);
                }
            } else if (data.frames != null) {
                for (frame in data.frames) {
                    var t = _assets.makeTile(frame);
                    if (t != null) {
                        tiles.push(t);
                    }
                }
            } else if (data.rect != null) {
                tiles.push(parseRect(data.rect));
            } else if (data.rects != null) {
                for (rect in data.rects) {
                    tiles.push(parseRect(rect));
                }
            } else {
                continue;
            }
            _assets.assets2D[key] = new Asset2D(key, tiles);
        }
        return _assets;
    }

    static function parseRect(rect: Rect): Tile {
        var color = new h3d.Vector(rect.color[0] / 255, rect.color[1] / 255, rect.color[2] / 255,
            rect.color[3] / 255);
        return new Tile(h2d.Tile.fromColor(0xFFFFFF, rect.width, rect.height), color,
            rect.scale == null ? 1.0 : rect.scale);
    }

    public function getAsset(name: String): Asset2D {
        return this.get(name);
    }

    public function get(name: String): Asset2D {
#if debug
        if (this.assets2D[name] == null) trace('Unable to find assets: "${name}"');
#end
        return this.assets2D[name];
    }
}
