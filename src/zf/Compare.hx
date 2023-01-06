package zf;

/**
	@stage:stable

	Standard compare functions for sorting

	Usage:

	var arr1: Array<String> = [ .... ]

	// positive number for ascending, negative for descending, if 0 always returns 0, i.e. no sort
	arr1.sort(Compare.string.bind(true, 1));
**/
class Compare {
	/**
		Sort string
	**/
	public static function string(ignoreCase: Bool, direction: Int, str1: String, str2: String): Int {
		if (ignoreCase == true) {
			str1 = str1.toUpperCase();
			str2 = str2.toUpperCase();
		}

		if (direction == 0 || str1 == str2) return 0;
		direction = direction > 0 ? 1 : -1;

		if (str1 > str2) return direction;
		return -(direction);
	}
}
