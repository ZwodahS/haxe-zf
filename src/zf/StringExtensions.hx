package zf;

/**
	@stage:stable
**/
class StringExtensions {
	public static function multiply(string: String, count: Int, joinString: String = "") {
		return [for (_ in 0...count) string].join(joinString);
	}
}
