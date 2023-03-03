package zf.resources;

import zf.Assets;
import zf.exceptions.ResourceLoadException;

/**
	@stage:stable

	Opinionated Res Manager

	Motivation

	It is quite bad to use spritesheet in the current form because I need to know which sheet
	the resource is located. The res manager goal is to allow spritesheet to be registered so that
	resource can just be directly access by name.

	Eventually other resources like Audio etc will be added.
	For now, fonts will also not be added here.
	Need to figure out how I want to handle translation and different font for different languages first.
**/
class ResourceManager {
	var images: Map<String, ImageResource>;

	public function new() {
		this.images = new Map<String, ImageResource>();
	}

	@:deprecated("Use loadSpritesheet directly")
	public function addSpritesheet(ss: LoadedSpritesheet) {
		for (asset in ss.assets) {
			final resource = new ImageResource(asset.id, asset.tiles);
			addImageResource(resource);
		}
	}

	public function loadSpritesheet(path: String) {
		final ss = Assets.loadAseSpritesheetConfig(path);
		if (ss == null) {
			Logger.warn('Fail to load spritesheet: ${path}');
			return;
		}

		for (asset in ss.assets) {
			final resource = new ImageResource(asset.id, asset.tiles);
			addImageResource(resource);
		}
	}

	public function registerBitmap(id: String, path: String) {
		final tile = hxd.Res.load(path).toTile();
		final t = new Tile(tile, new h3d.Vector(1, 1, 1, 1), 1.0, [0, 0]);
		final resource = new ImageResource(id, [t]);
		addImageResource(resource);
	}

	function addImageResource(resource: ImageResource) {
		if (this.images[resource.id] != null) Logger.warn('Duplicated image loaded: ${resource.id}');
		this.images[resource.id] = resource;
	}

	// ---- Getters ---- //

	@:deprecated
	inline public function getAsset2D(id: String): ImageResource {
		return getImageResource(id);
	}

	inline public function getImageResource(id: String): ImageResource {
		return this.images[id];
	}

	public function getTile(id: String, index: Int = 0): h2d.Tile {
		final asset = getImageResource(id);
		return asset == null ? null : asset.getTile(index);
	}

	public function getTiles(id: String, start: Int = 0, end: Int = -1): Array<h2d.Tile> {
		var asset = getImageResource(id);
		return asset == null ? null : asset.getTiles(start, end);
	}

	public function getBitmap(id: String, index: Int = 0, fallback: String = null): h2d.Bitmap {
		var asset = getImageResource(id);
		if (fallback != null && asset == null) asset = getImageResource(fallback);
		return asset == null ? null : asset.getBitmap(index);
	}

	public function getBitmaps(id: String, start: Int = 0, end: Int = -1, fallback: String = null): Array<h2d.Bitmap> {
		var asset = getImageResource(id);
		if (fallback != null && asset == null) asset = getImageResource(fallback);
		return asset == null ? null : asset.getBitmaps(start, end);
	}

	public function getAnim(id: String): h2d.Anim {
		final asset = getImageResource(id);
		return asset == null ? null : asset.getAnim();
	}

	public static function getJson(path: String, exception: Bool = true): Dynamic {
		try {
			final file = hxd.Res.load(path);
			final text = file.toText();
			final parsed = haxe.Json.parse(text);
			return parsed;
		} catch (e) {
			if (exception) throw new ResourceLoadException(path, e);
			return null;
		}
	}

	public static function getXml(path: String, exception: Bool = true): String {
		try {
			final string = hxd.Res.load(path).toText();
			return string;
		} catch (e) {
			if (exception) throw new ResourceLoadException(path, e);
			return null;
		}
	}
}

/**
	Sun 23:21:48 29 Jan 2023
	Refactor this slightly to decouple from Asset2D.
	Eventually might want to deprecate the old Assets
**/
