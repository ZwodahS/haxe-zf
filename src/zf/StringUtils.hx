package zf;

class StringUtils {
	inline public static function formatFloat(v: Float, dp: Int = 0): String {
		var str = '${v}';
		var split = str.split('.');
		if (split.length == 1) return split[0];
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
}
