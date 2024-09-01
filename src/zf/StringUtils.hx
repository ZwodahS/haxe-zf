package zf;

/**
	@stage:stable
**/
class StringUtils {
	inline public static function formatFloat(v: Float, dp: Int = 0): String {
		var str = '${v}';
		var split = str.split('.');
		if (split.length == 1 || dp == 0) return split[0];
		return split[0] + '.' + split[1].substring(0, dp);
	}

	/**
		For passing of function around rather than creating a function.
		i.e. StringUtils.equals.bind("#") instead of creating a function.
	**/
	public static function equals(v1: String, v2: String): Bool {
		return v1 == v2;
	}

	public static function findClosestMatch(stringList: Array<String>, str: String) {
		var closest = "";
		for (current in stringList) {
			if (current.indexOf(str) == 0 && (closest == "" || closest.length > current.length)) {
				closest = current;
			}
		}
		return closest;
	}

	public static function formatInt(v: Int, split: Int = 3, separator: String = ","): String {
		final str = '${v}';
		var i = str.length - 1;
		var c = 0;
		var out = [];
		while (i != -1) {
			out.push(str.charAt(i));
			c += 1;
			if (c == split && i != 0) {
				out.push(separator);
				c = 0;
			}
			i -= 1;
		}
		out.reverse();
		return out.join("");
	}
}
