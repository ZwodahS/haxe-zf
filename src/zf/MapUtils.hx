package zf;

class MapUtils {
	/**
		Provide a inline filter function for map utils.
		It is sometimes unsafe to remove item while iterating.
	**/
	public static function inFilter<K, V>(map: Map<K, V>, f: V->Bool) {
		/**
			f: return true to keep the element, false otherwise
		**/
		var keys = [for (k in map.keys()) k];

		for (k in keys) {
			if (!f(map[k])) map.remove(k);
		}
	}
}
