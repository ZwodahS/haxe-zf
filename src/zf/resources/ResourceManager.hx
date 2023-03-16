package zf.resources;

import zf.Assets;
import zf.exceptions.ResourceLoadException;
import zf.resources.LanguageFont;

typedef ResourceConf = {
	public var spritesheets: Array<{
		public var path: String;
	}>;

	public var fonts: Array<{
		public var path: String;
	}>;
}

enum ResourceSource {
	Pak;
	Dir;
}

/**
	@stage:stable

	Opinionated Res Manager

	Motivation

	There are a few reasons why this is created.

	1. We want to load images or any resources and be able to access them via a name, regardless of where it came from.
	2. We need to be able to load from both pak and userdata/mods

	One different between this and UserData is that we will not handle loading on web.
	This is because "Resource" is not the same as "Data" so we will not allow that on the web build

	Currently managing
	- Images
	- Text (unparsed)

	@todo
	- Add Structloader here
	Probably need 2 struct loader, one for struct loader and one for non-structloader
**/
class ResourceManager {
	/**
		Loaded images
	**/
	var images: Map<String, ImageResource>;

	/**
		Loaded Strings
	**/
	var texts: Map<String, String>;

	/**
		Loaded fonts
	**/
	public var fonts: Map<String, LanguageFont>;

	public function new() {
		this.images = new Map<String, ImageResource>();
		this.texts = new Map<String, String>();
		this.fonts = new Map<String, LanguageFont>();
	}

	public function load(p: String) {
		/**
			Thu 11:47:20 16 Mar 2023
			Eventually I want this to be smarter.

			For example, to be able to load them from res and also mod directory.
			Then we will need to be able to smarter and know the relative path.

			For nowe we don't have to deal with that.
		**/

		final path = new haxe.io.Path(p);

		final config: ResourceConf = getJson(p);
		if (config.spritesheets != null) {
			for (ssConf in config.spritesheets) {
				loadSpritesheet(ssConf.path);
			}
		}

		if (config.fonts != null) {
			for (fPath in config.fonts) {
				final f = loadFonts("fonts/fonts.json");
				this.fonts[f.language] = f;
			}
		}
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

	// ---- Images ---- //

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

	// ---- Fonts ---- //
	public function loadFonts(path: String, source: ResourceSource = Pak, exception: Bool = true): LanguageFont {
		try {
			final conf = getJson(path, source, exception);
			if (conf == null) return null;

			var langConf: LanguageFontConf = conf;
			final lang = langConf.language;

			final allFonts: Map<String, SingleLanguageFontType> = [];

			for (key => value in (langConf.fonts: DynamicAccess<Dynamic>)) {
				final c: FontConf = value;
				if (c.type == "msdf") {
					final msdfConf: MSDFConf = c.conf;
					// @todo, figure out how to load font from non-pak later
					final font = hxd.Res.load(msdfConf.file).to(hxd.res.BitmapFont);
					final fonts = [];
					for (v in msdfConf.size) fonts.push(font.toSdfFont(v, MultiChannel));
					allFonts[key] = {sourceFont: font, fonts: fonts};
				}
			}

			return {language: lang, fonts: allFonts};
		} catch (e) {
			Logger.exception(e);
			if (exception) throw new ResourceLoadException(path, e);
			return null;
		}
	}

	// ---- Static Loader ---- //
	public static function getString(path: String, source: ResourceSource = Pak, exception: Bool = true): String {
		try {
			var text: String = null;
			switch (source) {
				case Pak:
					final file = hxd.Res.load(path);
					text = file.toText();
				case Dir:
					// if not sys then we will not handle this
#if !sys
					return null;
#else
					text = sys.io.File.getContent(path);
#end
			}
			return text;
		} catch (e) {
			if (exception) throw new ResourceLoadException(path, e);
			return null;
		}
	}

	public static function getJson(path: String, source: ResourceSource = Pak, exception: Bool = true): Dynamic {
		try {
			final text = getString(path, source, exception);
			if (text == null) return null;
			final parsed = haxe.Json.parse(text);
			return parsed;
		} catch (e) {
			Logger.exception(e);
			if (exception) throw new ResourceLoadException(path, e);
			return null;
		}
	}
}

/**
	Sun 23:21:48 29 Jan 2023
	Refactor this slightly to decouple from Asset2D.
	Eventually might want to deprecate the old Assets

	Mon 11:42:06 13 Mar 2023
	Not adding the mod handling stuffs yet until I figure out how I want to handle it.
	We will slowly add the other resources later
**/
