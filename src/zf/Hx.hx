package zf;

class Hx {
	macro public static function swap(a, b) {
		return macro {var v = $a; $a = $b; $b = v;};
	}
}
