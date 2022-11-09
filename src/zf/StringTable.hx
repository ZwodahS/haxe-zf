package zf;

class StringTable {
	public var langs: Map<String, Map<String, haxe.Template>>;
	public var conf: Map<String, DynamicAccess<Dynamic>>;

	public static final Default = "en";

	public var currentLang = "en";

	public function new() {
		this.langs = new Map<String, Map<String, haxe.Template>>();
		this.conf = new Map<String, DynamicAccess<Dynamic>>();
	}

	public function getTemplate(id: String): haxe.Template {
		final table = langs[currentLang];
		if (table != null && table[id] != null) return table[id];
		final table = langs[Default];
#if debug
		if (table[id] == null) Logger.debug('- String not found in default lang: ${id}');
#end
		return table[id];
	}

	public function get(id: String, context: Dynamic = null): String {
		if (context == null) context = {}
		final template = this.getTemplate(id);
		if (template == null) return "";
		return template.execute(context);
	}

	public function load(lang: String, path: String) {
		try {
			final data = hxd.Res.load(path).toText();
			final conf: DynamicAccess<Dynamic> = haxe.Json.parse(data);
			// @todo if we have multiple strings, we will need to merge this later.
			this.conf[lang] = conf;
			final strings = new Map<String, haxe.Template>();

			function parse(c: DynamicAccess<Dynamic>, path: Array<String>) {
				for (id => value in c) {
					path.push(id);
					if (Std.isOfType(value, String)) {
						try {
							strings[path.join(".")] = new haxe.Template(value);
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
			parse(conf, []);
			this.langs[lang] = strings;
		} catch (e) {
			Logger.exception(e);
		}
	}
}
