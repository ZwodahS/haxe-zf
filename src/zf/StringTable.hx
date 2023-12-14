package zf;

/**
	@stage:stable
**/
class StringTable {
	public var langs: Map<String, Map<String, haxe.Template>>;
	public var confs: Map<String, Array<Dynamic>>;

	public static final Default = "en";

	public function new() {
		this.langs = [];
		this.confs = [];
	}

	inline public function getTemplate(id: String, lang: String, logError: Bool = true): haxe.Template {
		final table = langs[lang];
		if (table != null && table[id] != null) return table[id];

		final table = langs[Default];
#if debug
		if (logError == true && table[id] == null) Logger.debug('- String not found in default lang: ${id}');
#end
		return table[id];
	}

	public function get(id: String, lang: String, context: Dynamic = null, fallback: Array<String> = null,
			logError: Bool = true): String {
		if (context == null) context = {}

		final template = this.getTemplate(id, lang, fallback == null ? logError : false);
		if (template != null) return template.execute(context);
		if (fallback == null) return "";

		for (fId in fallback) {
			final template = this.getTemplate(fId, lang, false);
			if (template != null) return template.execute(context);
		}
		if (logError == true && fallback != null) Logger.debug('- String not found: ${id}, with fallback: ${fallback}');
		return "";
	}

	@:deprecated("Use Resource Manager instead")
	public function load(lang: String, path: String) {
		try {
			final data = hxd.Res.load(path).toText();
			final conf: Dynamic = haxe.Json.parse(data);
			loadStrings(lang, conf);
		} catch (e) {
			Logger.exception(e);
		}
	}

	/**
		This should be used only by resource manager, hence no exception is handled here.
	**/
	public function loadStrings(lang: String, data: Dynamic) {
		final t: DynamicAccess<Dynamic> = data;

		final strings = new Map<String, String>();
		function parse(c: DynamicAccess<Dynamic>, path: Array<String>) {
			for (id => value in c) {
				path.push(id);
				if (Std.isOfType(value, String)) {
					try {
						strings[path.join(".")] = value;
					} catch (e) {
						Logger.error('Error parsing string id: ${id}');
						Logger.error('${value}');
						Logger.exception(e);
					}
				} else {
					parse(value, path);
				}
				path.pop();
			}
		}
		parse(t, []);
		if (this.langs.exists(lang) == false) this.langs.set(lang, []);
		final langMap = this.langs[lang];
		for (key => t in strings) {
			if (langMap.exists(key) == true) Logger.debug('String replaced: ${key}');
			try {
				langMap.set(key, new haxe.Template(t));
			} catch (e) {
				Logger.error('Fail to parse string as template, id: ${key}');
				Logger.exception(e);
			}
		}
		if (this.confs.exists(lang) == false) this.confs.set(lang, []);
		this.confs[lang].push(data);
	}
}
