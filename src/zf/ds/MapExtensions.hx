package zf.ds;

class MapExtensions {
	public static function count<K, V>(map: Map<K, V>): Int {
		var count = 0;
		for (k in map.keys()) count += 1;
		return count;
	}

	public static function isEmpty<K, V>(map: Map<K, V>): Bool {
		for (k in map.keys()) return false;
		return true;
	}
}
