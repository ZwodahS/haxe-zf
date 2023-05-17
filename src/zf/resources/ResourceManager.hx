package zf.resources;

import zf.Assets;
import zf.exceptions.ResourceLoadException;
import zf.resources.LanguageFont;
import zf.resources.SoundResource;

typedef ResourceConf = {
	public var spritesheets: Array<{
		public var path: String;
	}>;

	public var fonts: Array<{
		public var path: String;
	}>;
	public var sounds: Array<{
		public var path: String;
	}>;
}

enum ResourceSource {
	Pak;
	Dir;
}

/**
	@stage:stable

	Opinionated Resource Manager

	Motivation

	There are a few reasons why this is created.

	1. We want to load images or any resources and be able to access them via a name, regardless of where it came from.
	2. We need to be able to load from both pak and userdata/mods

	Currently managing
	- Images
	- Text (unparsed)
	- Sound

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
		Cache Loaded Strings from getString method
	**/
	var strings: Map<String, String>;

	var sounds: Map<String, SoundResource>;

	/**
		Loaded fonts
	**/
	public var fonts: Map<String, LanguageFont>;

	public function new() {
		this.images = new Map<String, ImageResource>();
		this.strings = new Map<String, String>();
		this.fonts = new Map<String, LanguageFont>();
		this.sounds = new Map<String, SoundResource>();
	}

	public function load(p: String) {
		/**
			Thu 11:47:20 16 Mar 2023
			Eventually I want this to be smarter.

			For example, to be able to load them from res and also mod directory.
			Then we will need to be able to smarter and know the relative path.

			For now we don't have to deal with that.

			Mon 16:40:01 15 May 2023
			One idea is to always load from hxd.res
			If the path starts with @workshop:/... then we will load from steamworkshop
			If the path starts with @mod:/... then we will load from userdata/mod directory
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
				final f = loadFonts(fPath.path);
				this.fonts[f.language] = f;
			}
		}

		if (config.sounds != null) {
			for (c in config.sounds) {
				loadSounds(c.path);
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
#if debug
		if (asset == null) Logger.warn('Bitmap not found :${id}');
#end
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
	function loadFonts(path: String, source: ResourceSource = Pak, exception: Bool = true): LanguageFont {
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

	// ---- Sound ---- //
	public function getSound(name: String) {
		return this.sounds.get(name);
	}

	function loadSound(path: String): hxd.res.Sound {
		return hxd.Res.load(path).toSound();
	}

	function loadSounds(path: String, source: ResourceSource = Pak, exception: Bool = true) {
		try {
			final conf = getJson(path, source, exception);
			if (conf == null) return;
			var soundConf: {sound: Array<SoundResourceConf>} = conf;
			final sounds = soundConf.sound;
			for (conf in sounds) {
				final resource = new SoundResource(conf.id);
				for (s in conf.items) {
					final sound = new Sound();
					if (s.name != null) sound.name = s.name;
					if (s.ogg != null) sound.ogg = loadSound(s.ogg);
					if (s.pitch != null) sound.pitch = s.pitch;
					resource.items.push(sound);
				}
				this.sounds[resource.id] = resource;
			}
		} catch (e) {
			Logger.exception(e);
			if (exception) throw new ResourceLoadException(path, e);
		}
	}

	public function getFont(lang: String, id: String, sizeIndex: Int): h2d.Font {
		final fonts = getFonts(lang, id);
		if (fonts == null) return hxd.res.DefaultFont.get().clone();
		if (sizeIndex >= fonts.fonts.length) {
			sizeIndex = fonts.fonts.length - 1;
		}
		return fonts.fonts[sizeIndex];
	}

	public function getFonts(lang: String, id: String): SingleLanguageFontType {
		var langFont = this.fonts[lang];
		if (langFont == null) this.fonts["default"];
		var fonts = langFont.fonts[id];
		if (fonts == null) fonts = langFont.fonts["default"];
		return fonts;
	}

	public function getString(path: String, source: ResourceSource = Pak, exception: Bool = true): String {
		try {
			var text: String = null;
			if (this.strings[path] != null) return this.strings[path];
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
#if !debug
			// if not debug mode, we will cache this
			this.strings[path] = text;
#end
			return text;
		} catch (e) {
			if (exception) throw new ResourceLoadException(path, e);
			return null;
		}
	}

	// ---- Static Loader ---- //
	public function getJson(path: String, source: ResourceSource = Pak, exception: Bool = true): Dynamic {
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
