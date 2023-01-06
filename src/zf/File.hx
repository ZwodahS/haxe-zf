package zf;

using StringTools;

/**
	@stage:deprecating
**/
class File {
	/**
		Fri 10:47:38 06 Jan 2023
		I think there should be a better place to handle this.
		Also, the code should be better if we first replace \r\n with \n then split by \n
	**/
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
		// handle OS "Windows" | "Linux" | "BSD" | "Mac"
		switch (Sys.systemName()) {
			case "Windows":
				strings = text.split("\r\n");
			default:
				strings = text.split('\n');
		}
		return strings;
	}
}
