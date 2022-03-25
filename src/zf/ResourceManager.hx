package zf;

import zf.Assets;

/**
	Opinionated Res Manager

	Fri 13:08:23 28 Jan 2022
	Motivation

	It is quite bad to use spritesheet in the current form because I need to know which sheet
	the resource is located. The res manager goal is to allow spritesheet to be registered so that
	resource can just be directly access by name.

	Eventually other resources like Audio etc will be added.
	For now, fonts will also not be added here.
	Need to figure out how I want to handle translation and different font for different languages first.
**/
class ResourceManager {
	var assets2D: AssetsMap;

	/**
		Stores font name to a map of different font sizes.

		Fri 13:44:41 28 Jan 2022 not sure if we need to store the bitmap version.
		for now we will not.
	**/
	public function new() {
		this.assets2D = new AssetsMap();
	}

	public function addSpritesheet(ss: LoadedSpritesheet) {
		for (asset in ss.assets) {
			this.assets2D.add(asset);
		}
	}

	// ---- Proxy method for Asset2D ---- //
	inline public function getAsset2D(id: String): Asset2D {
		return this.assets2D.get(id);
	}

	public function getTile(id: String, index: Int = 0): h2d.Tile {
		final asset = getAsset2D(id);
		return asset == null ? null : asset.getTile(index);
	}

	public function getTiles(id: String, start: Int = 0, end: Int = -1): Array<h2d.Tile> {
		final asset = getAsset2D(id);
		return asset == null ? null : asset.getTiles(start, end);
	}

	public function getBitmap(id: String, index: Int = 0): h2d.Bitmap {
		final asset = getAsset2D(id);
		return asset == null ? null : asset.getBitmap(index);
	}

	public function getBitmaps(id: String, start: Int = 0, end: Int = -1): Array<h2d.Bitmap> {
		final asset = getAsset2D(id);
		return asset == null ? null : asset.getBitmaps(start, end);
	}

	public function getAnim(id: String): h2d.Anim {
		final asset = getAsset2D(id);
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
}
