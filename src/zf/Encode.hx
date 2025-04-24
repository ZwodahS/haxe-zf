package zf;

class Encode {
	public static final Base26 = [
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
		"W", "X", "Y", "Z"
	];

	public static final Base26Decode = [for (ind => c in Base26) c => ind];

	// ---- Encoding ---- //

	/**
		Encode any int to a base 26, i.e. A-Z
	**/
	public static function encodeIntBase26(i: Int, minLength: Null<Int> = null): String {
		return encodeInt(i, Base26, minLength);
	}

	public static function encodeIntsBase26(ints: Array<Int>, minLength: Null<Int> = null): Array<String> {
		return encodeInts(ints, Base26, minLength);
	}

	public static function encodeInt(i: Int, charset: Array<String>, minLength: Null<Int> = null): String {
		var s = "";
		while (i > 0) {
			final r = i % charset.length;
			s = charset[r] + s;
			i = Std.int(i / 26);
		}
		if (minLength != null) return StringTools.lpad(s, charset[0], minLength);
		return s;
	}

	public static function encodeInts(ints: Array<Int>, charset: Array<String>,
			minLength: Null<Int> = null): Array<String> {
		var strings = [];
		for (i in ints) strings.push(encodeInt(i, charset, minLength));
		return strings;
	}

	// ---- Decoding ---- //
	public static function decodeIntBase26(str: String): Int {
		return decodeInt(str, Base26Decode, 26);
	}

	public static function decodeIntsBase26(strs: Array<String>): Array<Int> {
		return decodeInts(strs, Base26Decode, 26);
	}

	static function decodeInt(str: String, decode: Map<String, Int>, base: Int): Int {
		var i = 0;
		for (x in 0...str.length) i += Std.int(Math.pow(base, str.length - x - 1)) * (decode.get(str.charAt(x)) ?? 0);
		return i;
	}

	static function decodeInts(strs: Array<String>, decode: Map<String, Int>, base: Int): Array<Int> {
		final ints: Array<Int> = [];
		for (s in strs) ints.push(decodeInt(s, decode, base));
		return ints;
	}
}
