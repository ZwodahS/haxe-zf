
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

    public function new(t: h2d.Tile, color: h3d.Vector) {
        this.tile = t;
        this.color = color;
    }

    public function getBitmap(scale: Float = 1): h2d.Bitmap {
        var bm: h2d.Bitmap = new h2d.Bitmap(this.tile);
        bm.color = this.color;
        bm.scaleX = scale;
        bm.scaleY = scale;
        return bm;
    }

    public function copy(): Tile {
        var t = new Tile(this.tile, this.color);
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
    public var scale: Float;

    public var count(get, null): Int;

    public function get_count(): Int {
        return this.tiles.length;
    }

    public function new(key, tiles, scale: Float=1) {
        this.key = key;
        this.tiles = tiles;
        this.scale = scale;
    }

    public function getBitmap(pos: Int = 0): h2d.Bitmap{
        if (pos < 0 || pos >= this.tiles.length) {
            pos = 0;
        }
        return this.tiles[pos].getBitmap(this.scale);
    }

    public function getBitmaps(start: Int = 0, end: Int = -1): Vector<h2d.Bitmap> {
        if (end == -1) {
            end = this.tiles.length;
        }
        var out = new Vector<h2d.Bitmap>(end - start);
        var ind = 0;
        for (i in start...end) {
            out[ind++] = this.tiles[i].getBitmap(this.scale);
        }
        return out;
    }

    public function getTiles(): Array<h2d.Tile> {
        var out = new Array<h2d.Tile>();
        for (i in 0...this.tiles.length) {
            out.push(this.tiles[i].tile);
        }
        return out;
    }

}

typedef Frame = {
    var src: String;
    var key: String;
    var color: Array<Int>;
    var scale: Null<Float>;
}

typedef Rect = {
    var width: Int;
    var height: Int;
    var color: Array<Int>;
}

typedef Data = {
    var rect: Rect;
    var frame: Frame;
    var frames: Array<Frame>;
    var scale: Null<Float>;
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
        var jsonText = hxd.Res.load(filename+".json").toText();
        var parsed = haxe.Json.parse(jsonText);

        var data = new Map<String, TileConf>();

        for (key in Reflect.fields(parsed)) {
            data[key] = Reflect.field(parsed, key);
        }

        // open the image file
        var image = hxd.Res.load(filename+".png").toTile();
        for (k => v in data) {
            v.image = image.sub(v.x, v.y, v.w, v.h);
        }
        this.assetsMap[filename] = data;

        return data;
    }

    private function getTile(src: String, key: String): h2d.Tile {
        var map = this.getAssetsMap(src);
        return map[key].image;
    }

    inline function makeTile(frame: Frame): Tile {
        var color: h3d.Vector;
        if (frame.color != null) {
            color = new h3d.Vector(
                frame.color[0]/255, frame.color[1]/255, frame.color[2]/255, frame.color[3]/255
            );
        } else {
            color = new h3d.Vector(1.0, 1.0, 1.0, 1.0);
        }
        return new Tile(this.getTile(frame.src, frame.key), color);
    }

    public static function parseAssets(assetPath: String): Assets {
        var _assets = new Assets();
        var jsonText = hxd.Res.load(assetPath).toText();
        var parsed = haxe.Json.parse(jsonText);

        for (key in Reflect.fields(parsed)) {
            var data: Data = Reflect.field(parsed, key);
            var tiles = new Array<Tile>();
            var scale = 1.0;
            if (data.frame != null) {
                tiles.push(_assets.makeTile(data.frame));
                if (data.frame.scale != null) {
                    scale = data.frame.scale;
                }
            } else if (data.frames != null) {
                for (frame in data.frames) {
                    tiles.push(_assets.makeTile(frame));
                }
            } else if (data.rect != null) {
                var color = new h3d.Vector(
                    data.rect.color[0]/255,
                    data.rect.color[1]/255,
                    data.rect.color[2]/255,
                    data.rect.color[3]/255
                );
                tiles.push(new Tile(
                    h2d.Tile.fromColor(0xFFFFFF, data.rect.width, data.rect.height), color
                ));
            }
            if (data.scale != null) {
                scale = data.scale;
            }
            _assets.assets2D[key] = new Asset2D(key, tiles, scale);
        }

        return _assets;
    }

    public function getAsset(name: String): Asset2D {
        return this.assets2D[name];
    }
}
