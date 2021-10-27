package zf;

using StringTools;

class File {
	public static function loadStringsFromFile(path: String): Array<String> {
		var f: hxd.res.Any = null;
		try {
			f = hxd.Res.load(path);
		} catch (e) {
			Logger.debug('${e}');
			return null;
		}
		final text = f.toText().trim();

		var strings: Array<String> = null;
#if strings
		= text.split('\n');
#else
		// handle OS "Windows" | "Linux" | "BSD" | "Mac"
		switch (Sys.systemName()) {
			case "Windows":
				strings = text.split("\r\n");
			default:
				strings = text.split('\n');
		}
#end
		return strings;
	}
}
