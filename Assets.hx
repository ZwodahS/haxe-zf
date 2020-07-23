package common;

import haxe.DynamicAccess;
import haxe.ds.Vector;

import common.h2d.StateObject;

/**
    Tile is a combination of Tile:h2d.Tile + color:h3d.Vector + Float scale
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
        var bm: h2d.Bitmap = new h2d.Bitmap(this.tile.clone());
        bm.color = this.color.clone();
        bm.scaleX = this.scale;
        bm.scaleY = this.scale;
        return bm;
    }

    public function copy(): Tile {
        var t = new Tile(this.tile.clone(), this.color, this.scale);
        return t;
    }

    public function sub(x: Int, y: Int, w: Int, h: Int) {
        return new Tile(this.tile.sub(x, y, w, h), this.color.clone(), this.scale);
    }
}

/**
    Asset is the parent class of all assets
**/
class Asset {
    public function new() {}
}

/**
    Asset2D defines a 2D graphical asset.
**/
class Asset2D extends Asset {
    public var tiles(default, null): Array<Tile>;
    public var count(get, null): Int;

    public function get_count(): Int {
        return this.tiles.length;
    }

    public function new(tiles) {
        super();
        this.tiles = tiles;
    }

    public function getBitmap(pos: Int = 0): h2d.Bitmap {
        if (pos < 0 || pos >= this.tiles.length) pos = 0;
        return this.tiles[pos].getBitmap();
    }

    public function getBitmaps(start: Int = 0, end: Int = -1): Vector<h2d.Bitmap> {
        if (end <= 0) end = this.tiles.length;
        if (start < 0 || start >= end) start = end - 1;
        var out = new Vector<h2d.Bitmap>(end - start);
        var ind = 0;
        for (i in start...end) out[ind++] = this.tiles[i].getBitmap();
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

/**
    Anim2D stores all the data needed to create a h2d.Anim
**/
class Anim2D extends Asset2D {
    public var loop: Bool;
    public var speed: Float;
    public var center: Point2f;

    public function new(frames: Array<Tile>, loop: Bool, speed: Float, center: Point2f) {
        super(frames);
        this.loop = loop;
        this.speed = speed;
        this.center = center;
    }

    override public function getAnim(): h2d.Anim {
        var anim = new h2d.Anim(getTiles(), this.speed);
        anim.loop = this.loop;
        if (this.center.x != 0 && this.center.y != 0) {
            for (f in anim.frames) {
                f.dx = -this.center.x;
                f.dy = -this.center.y;
            }
        }
        anim.x = this.center.x;
        anim.y = this.center.y;
        return anim;
    }
}

/**
    Object2D defines an object-type asset for 2D graphics, storing states and their respective Asset2D
**/
class Object2D extends Asset {
    public var states: Map<String, Asset2D>;

    public function new() {
        super();
        this.states = new Map<String, Asset2D>();
    }

    public function getState(state: String): Asset2D {
        return states[state];
    }

    public function createStateObject(?layer: h2d.Layers): StateObject {
        var obj = new StateObject(layer);
        for (s => asset in this.states) {
            if (Std.is(asset, Anim2D)) {
                var a = cast(asset, Anim2D);
                obj.addState(s, a.getAnim());
            } else {
                obj.addState(s, asset.getBitmap());
            }
        }
        return obj;
    }
}

////// Definition for json parsing

/**
    Image define a single reference to an image
    There are a few ways to define it.
    1. img: specify the image path.
    2. src + key: specify the json path and the key to use. The json is the descriptor for a spritesheet.
**/
typedef ImageDefinition = {
    var img: String;
    var src: Null<String>;
    var key: Null<String>;

    var color: Array<Int>;
    var scale: Null<Float>;
    // TODO: may need to add "center" to image definition in the future.
    var ?region: {
        x: Int,
        y: Int,
        w: Int,
        h: Int
    };
}

/**
    ImageGroupDefinition defines a list of images.
    It has a default "src" attribute, which will be used when processing all the images
    Each of these images can provide their own src or just use the default src with a key
**/
typedef ImageGroupDefinition = {
    var src: Null<String>;
    var images: Array<ImageDefinition>;
}

/**
    Rect define a simple way to create h2d.Tile from a Rectangle.
    This is usually used for prototyping and allow us to swap out for real assets when it is ready.
**/
typedef RectDefinition = {
    var width: Int;
    var height: Int;
    var color: Array<Int>;
    var scale: Null<Float>;
}

/**
    Anim define an animation. This is used to create h2d.Anim
    It provide a default src value that can be used by all the child node.
**/
typedef AnimDefinition = {
    var src: String;
    var loop: Null<Bool>;
    var speed: Null<Float>;
    var frames: Array<ImageDefinition>;
    var center: {x: Int, y: Int};
}

/**
    Object define an object with various state
    it also provide a default src which all the child can use, since most of the time they will below to the same sheet.
**/
typedef ObjectDefinition = {
    var src: Null<String>;
    var file: Null<String>;
    var states: DynamicAccess<ObjectStateDefinition>;
}

/**
    Provide a definition for a single state, either via an animation or single image
**/
typedef ObjectStateDefinition = {
    var image: ImageDefinition; // single frame
    var anim: AnimDefinition; // multiple frame
}

/**
    GraphicDefinition provide the definition of a node in graphics key
**/
typedef GraphicDefinition = {
    var rect: RectDefinition;
    var image: ImageDefinition;
    var images: ImageGroupDefinition;
    var anim: AnimDefinition;
}

/**
    Known limitation

    1. Animation or ImageGroupDefinition cannot use Rect. The main reason is that rect is usually used during prototyping via
    shapes. After that it will not be used.
**/
typedef SpritesheetConfig = {
    var gridtype: String;
    var gridsize: {var x: Int; var y: Int;};
    var frames: DynamicAccess<{
        var x: Int;
        var y: Int;
        var w: Null<Int>;
        var h: Null<Int>;
    }>;
}

/**
    AssetsConf
**/
typedef AssetsConf = {
    var includes: Array<String>;
    var graphics: DynamicAccess<GraphicDefinition>;
    var objects: DynamicAccess<ObjectDefinition>;
    var fonts: Array<String>;
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
        sourceSize: {w: Int, h: Int},
        duration: Int,
    }>,
    meta: {
        image: String, frameTags: Array<{
            name: String,
            from: Int,
            to: Int,
            direction: String
        }>,
    }
}

/**
    Assets is the main loader and assets container.

    Known limitation

    1. Animation or ImageGroupDefinition cannot use Rect. The main reason is that rect is usually used during prototyping via
    shapes. After that it will not be used.
**/
class Assets {
    // assetsMap store the key -> config for a spritesheet
    var assetsMap: Map<String, Map<String, h2d.Tile>>;
    // assets store the mapping from assets.json
    var assets2D: Map<String, Asset2D>;
    var objects2D: Map<String, Object2D>;
    var fonts: Map<String, hxd.res.BitmapFont>;

    public function new() {
        assetsMap = new Map<String, Map<String, h2d.Tile>>();
        assets2D = new Map<String, Asset2D>();
        objects2D = new Map<String, Object2D>();
        fonts = new Map<String, hxd.res.BitmapFont>();
    }

    public static function loadSpritesheet(filename: String): Map<String, h2d.Tile> {
        // open the json file
        var jsonText = hxd.Res.load(filename + ".json").toText();
        var parsed: SpritesheetConfig = haxe.Json.parse(jsonText);

        var data = new Map<String, h2d.Tile>();
        var image = hxd.Res.load(filename + ".png").toTile();
        // parse the config file
        if (parsed.gridtype == "fixed") {
            var gridsize = parsed.gridsize;
            for (key => value in parsed.frames) {
                var w = value.w == null ? 1 : value.w;
                var h = value.h == null ? 1 : value.h;
                data[key] = image.sub(value.x * gridsize.x, value.y * gridsize.y, w * gridsize.x,
                    h * gridsize.y);
            }
        } else {
            for (key => value in parsed.frames) {
                var w = value.w == null ? 1 : value.w;
                var h = value.h == null ? 1 : value.h;
                data[key] = image.sub(value.x, value.y, w, h);
            }
        }
        return data;
    }

    // Wed Jul 22 16:12:21 2020
    // may want to do more with asesprite in the future, i.e. augment it with other configuration.
    // for now this will do.
    public static function loadAseSpritesheetConfig(filename: String): Map<String, Asset2D> {
        var jsonText = hxd.Res.load(filename).toText();
        var parsed: AseSpritesheetConfig = haxe.Json.parse(jsonText);

        var data = new Map<String, Asset2D>();
        var directory = haxe.io.Path.directory(filename);
        var image = hxd.Res.load(haxe.io.Path.join([directory, parsed.meta.image])).toTile();

        // for each frameTags, we export
        for (frame in parsed.meta.frameTags) {
            var tiles: Array<Tile> = [];
            for (i in frame.from...frame.to + 1) {
                var f = parsed.frames[i].frame;
                var t = new Tile(image.sub(f.x, f.y, f.w, f.h), new h3d.Vector(1, 1, 1, 1), 1.0);
                tiles.push(t);
            }
            data[frame.name] = new Asset2D(tiles);
        }
        return data;
    }

    public function getSpritesheet(filename: String): Map<String, h2d.Tile> {
        if (this.assetsMap[filename] == null) {
            var data = loadSpritesheet(filename);
            this.assetsMap[filename] = data;
        }
        return this.assetsMap[filename];
    }

    private function getTile(src: String, key: String): h2d.Tile {
        var map = this.getSpritesheet(src);
        if (map[key] == null) {
            return null;
        }
        return map[key];
    }

    inline function makeTile(image: ImageDefinition, src: String = null): Tile {
        var color: h3d.Vector;
        if (image.color != null) {
            color = new h3d.Vector(image.color[0] / 255, image.color[1] / 255, image.color[2] / 255,
                image.color[3] / 255);
        } else {
            color = new h3d.Vector(1.0, 1.0, 1.0, 1.0);
        }
        if (image.src != null) src = image.src;
        var t: h2d.Tile = null;
        if (image.img != null) {
            t = hxd.Res.load(image.img).toTile();
        } else if (src != null) {
            t = this.getTile(src, image.key);
        } else {
#if debug
            trace('src not specified for ${image.key}');
#end
        }

        if (image.region != null) {
            t = t.sub(image.region.x, image.region.y, image.region.w, image.region.h);
        }

        if (t == null) {
#if debug
            trace('Unable to load assets: ${image.key} or ${image.img}');
#end
            return null;
        }
        return new Tile(t, color, image.scale == null ? 1.0 : image.scale);
    }

    public static function parseAssets(assetPath: String): Assets {
        var _assets = new Assets();
        _assets.loadAssetConf(assetPath);
        return _assets;
    }

    private function loadAssetConf(assetPath: String) {
        var jsonText = hxd.Res.load(assetPath).toText();
        var parsed: AssetsConf = haxe.Json.parse(jsonText);

        for (key => graphic in parsed.graphics) {
            this.assets2D[key] = parseGraphicDefinition(graphic);
        }

        for (key => objectDef in parsed.objects) {
            if (objectDef.file != null) {
                objectDef = parseObjectDefFile(objectDef.file);
            }
            var object = new Object2D();
            for (stateName => objectState in objectDef.states) {
                object.states[stateName] = parseObjectState(objectState, objectDef.src);
            }
            this.objects2D[key] = object;
        }

        if (parsed.fonts != null) {
            for (font in parsed.fonts) {
                this.fonts[font] = hxd.Res.load('fnt_${font}.fnt').to(hxd.res.BitmapFont);
            }
        }

        if (parsed.includes != null) {
            for (include in parsed.includes) {
                loadAssetConf(include);
            }
        }
    }

    function parseObjectDefFile(filename: String): ObjectDefinition {
        var jsonText = hxd.Res.load(filename).toText();
        var parsed: ObjectDefinition = haxe.Json.parse(jsonText);
        return parsed;
    }

    function parseObjectState(objectState: ObjectStateDefinition, ?src: String): Asset2D {
        if (objectState.image != null) {
            return parseImageDefinition(objectState.image, src);
        } else if (objectState.anim != null) {
            return parseAnimDefinition(objectState.anim, src);
        }
        return null;
    }

    function parseGraphicDefinition(graphic: GraphicDefinition): Asset2D {
        if (graphic.image != null) {
            // typedef ImageDefinition
            return parseImageDefinition(graphic.image);
        } else if (graphic.images != null) {
            // This should likely be deprecated once object comes around.
            // typedef ImageGroupDefinition
            var tiles = new Array<Tile>();
            for (image in graphic.images.images) {
                var t = makeTile(image, graphic.images.src);
                if (t != null) {
                    tiles.push(t);
                }
            }
            return new Asset2D(tiles);
        } else if (graphic.rect != null) {
            var t = parseRect(graphic.rect);
            return new Asset2D([t]);
        } else if (graphic.anim != null) {
            return parseAnimDefinition(graphic.anim);
        } else {
            return null;
        }
    }

    function parseImageDefinition(image: ImageDefinition, ?src: String): Asset2D {
        var t = makeTile(image, src);
        if (t == null) return null;
        return new Asset2D([t]);
    }

    function parseAnimDefinition(anim: AnimDefinition, ?src: String): Anim2D {
        if (anim.src != null) src = anim.src;
        var speed = anim.speed == null ? 1.0 : anim.speed;
        var loop = anim.loop == null ? true : anim.loop;
        var tiles = new Array<Tile>();
        for (frame in anim.frames) {
            var t = makeTile(frame, src);
            tiles.push(t);
        }

        var center: Point2f = [0, 0];
        if (anim.center != null) {
            center.x = anim.center.x;
            center.y = anim.center.y;
        }

        return new Anim2D(tiles, loop, speed, center);
    }

    static function parseRect(rect: RectDefinition): Tile {
        var color = new h3d.Vector(rect.color[0] / 255, rect.color[1] / 255, rect.color[2] / 255,
            rect.color[3] / 255);
        return new Tile(h2d.Tile.fromColor(0xFFFFFF, rect.width, rect.height), color,
            rect.scale == null ? 1.0 : rect.scale);
    }

    public function getAsset2D(name: String): Asset2D {
#if debug
        if (this.assets2D[name] == null) trace('Unable to find assets: "${name}"');
#end
        return this.assets2D[name];
    }

    public function getAnim2D(name: String): Anim2D {
        var a = getAsset2D(name);
        if (a == null) return null;
        if (!Std.is(a, Anim2D)) return null;
        return cast(a, Anim2D);
    }

    public function getObject2D(name: String): Object2D {
#if debug
        if (this.objects2D[name] == null) trace('Unable to find assets: "${name}"');
#end
        return this.objects2D[name];
    }

    public function getFont(name: String): hxd.res.BitmapFont {
        return this.fonts[name];
    }
}
