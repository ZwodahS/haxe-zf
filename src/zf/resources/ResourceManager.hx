package zf.resources;

using StringTools;

import zf.exceptions.ResourceLoadException;
import zf.resources.LanguageResource;
import zf.resources.ResourceConf;
import zf.resources.FontResource;
import zf.resources.SoundResource;

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
	- String Table
	- Fonts
**/
class ResourceManager {
	/**
		Loaded images
	**/
	final images: Map<String, ImageResource>;

	/**
		Cache Loaded Strings from getString method
	**/
	final strings: Map<String, String>;

	final sounds: Map<String, SoundResource>;

	/**
		Loaded fonts for each language
	**/
	public final fonts: Map<String, Map<String, LoadedFontGroup>>;

	/**
		Loaded font groups
	**/
	public final fontGroups: Map<String, Map<String, LoadedFontGroup>>;

	/**
		Loaded languages
	**/
	public final languages: Map<String, LanguageResource>;

	/**
		Loaded String table
	**/
	public final stringTable: StringTable;

	public function new() {
		this.images = [];
		this.strings = [];
		this.fonts = [];
		this.fontGroups = [];
		this.sounds = [];
		this.languages = [];
		this.stringTable = new StringTable();
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

		final config: ResourceConf = getJsonFromPath(p);
		if (config.spritesheets != null) {
			for (ssConf in config.spritesheets) loadSpritesheet(ssConf.path);
		}

		if (config.fonts != null) {
			for (fPath in config.fonts) loadFonts(fPath.path);
		}

		if (config.sounds != null) {
			for (c in config.sounds) loadSounds(c.path);
		}

		if (config.languages != null) {
			for (c in config.languages) loadLanguage(c.path);
		}
	}

	public function loadSpritesheet(path: String) {
		try {
			final jsonText = hxd.Res.load(path).toText();
			final parsed: AseSpritesheetConfig = haxe.Json.parse(jsonText);

			final directory = haxe.io.Path.directory(path);
			final image = hxd.Res.load(haxe.io.Path.join([directory, parsed.meta.image])).toTile();

			for (frame in parsed.meta.frameTags) {
				final tiles: Array<Tile> = [];
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
				final resource = new ImageResource(frame.name, tiles);
				addImageResource(resource);
			}
		} catch (e) {
			Logger.exception(e);
			Logger.warn('Fail to load spritesheet: ${path}');
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

	@:deprecated("Use getImageResource")
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

	public function getAnim(id: String, start: Int = 0, end: Int = -1): h2d.Anim {
		final asset = getImageResource(id);
		return asset == null ? null : asset.getAnim(1, null, start, end);
	}

	// ---- Fonts ---- //
	function loadFonts(path: String, source: ResourceSource = Pak, exception: Bool = true) {
		try {
			final conf = getJsonFromPath(path, source, exception);
			if (conf == null) return;

			final langFile: FontFile = conf;
			// load all the defined font group in the file
			for (group in langFile.fonts) {
				if (this.fontGroups.exists(group.id) == false) this.fontGroups.set(group.id, []);
				final loaded = this.fontGroups[group.id];
				for (id => f in (group.fonts: DynamicAccess<Dynamic>)) {
					final c: FontConf = f;
					if (c.type == "msdf") {
						final msdf: MSDFConf = c.conf;
						if (msdf.file.startsWith("@")) {
							// not implemented. Need to implement @workshop and @mod ??
							Logger.debug('Not Implemented file path: "${msdf.file}"', "[Resource]");
						} else {
							// read from res
							final font = hxd.Res.load(msdf.file).to(hxd.res.BitmapFont);
							final fonts = [];
							for (v in msdf.size) fonts.push(font.toSdfFont(v, MultiChannel));
							loaded[id] = {sourceFont: font, fonts: fonts};
							Logger.debug('Font loaded ${msdf.file} to ${group.id}.${id}', "[Resource]");
						}
					}
				}
			}
		} catch (e) {
			Logger.exception(e);
			if (exception) throw new ResourceLoadException(path, e);
		}
	}

	inline public function getFont(lang: String, id: String, sizeIndex: Int): h2d.Font {
		final fonts = getFonts(lang, id);
		if (fonts == null) return hxd.res.DefaultFont.get().clone();
		if (sizeIndex >= fonts.fonts.length) {
			sizeIndex = fonts.fonts.length - 1;
		}
		return fonts.fonts[sizeIndex];
	}

	inline public function getFonts(lang: String, id: String): LoadedFontGroup {
		var langFont = this.fonts[lang];
		if (langFont == null) langFont = this.fontGroups["default"];
		var fonts = langFont[id];
		if (fonts == null) fonts = this.fontGroups["default"].get(id);
		return fonts;
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
			final conf = getJsonFromPath(path, source, exception);
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
					if (s.volume != null) sound.volume = s.volume;
					resource.items.push(sound);
				}
				this.sounds[resource.id] = resource;
			}
		} catch (e) {
			Logger.exception(e);
			if (exception) throw new ResourceLoadException(path, e);
		}
	}

	// ---- Language ---- //
	function loadLanguage(path: String, source: ResourceSource = Pak, exception: Bool = true) {
		try {
			final conf: LanguageResource = getJsonFromPath(path + "/config.json", source, exception);
			if (conf == null) return;
			for (stringPath in conf.strings) {
				final languageStrings = getJsonFromPath(haxe.io.Path.join([path, stringPath]), source, exception);
				this.stringTable.loadStrings(conf.key, languageStrings);
			}
			if (conf.font.name != null) {
				this.fonts[conf.key] = new Map<String, LoadedFontGroup>();
				for (key => d in this.fontGroups["default"]) {
					var fg = d;
					if (this.fontGroups.exists(conf.font.name) == true
						&& this.fontGroups[conf.font.name].exists(key) == true) {
						fg = this.fontGroups[conf.font.name][key];
					}
					this.fonts[conf.key].set(key, fg);
				}
			} else {
				this.fonts[conf.key] = this.fontGroups["default"];
			}
		} catch (e) {
			Logger.exception(e);
			if (exception) throw new ResourceLoadException(path, e);
		}
	}

	// ---- Static Loader ---- //

	public function getStringFromPath(path: String, source: ResourceSource = Pak, exception: Bool = true): String {
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

	public function getJsonFromPath(path: String, source: ResourceSource = Pak, exception: Bool = true): Dynamic {
		try {
			final text = getStringFromPath(path, source, exception);
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

	Mon 12:50:50 06 Nov 2023
	Start moving more stuffs here.
	Font loading is upgraded. StringTable is also stored here so we can load strings here.

	Tue 15:22:25 26 Dec 2023
	Deleted zf.Assets and move the spritesheet loading here.
**/
