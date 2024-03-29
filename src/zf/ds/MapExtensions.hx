package zf.ds;

/**
	@stage:stable
**/
class MapExtensions {
	/**
		Counter the number of item in a map
	**/
	public static function count<K, V>(map: Map<K, V>): Int {
		var count = 0;
		for (k in map.keys()) count += 1;
		return count;
	}

	/**
		Check if the map is empty
	**/
	public static function isEmpty<K, V>(map: Map<K, V>): Bool {
		for (k in map.keys()) return false;
		return true;
	}

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

	public static function toArray<K, V>(map: Map<K, V>, filter: (K, V) -> Bool = null) {
		final out: Array<V> = [];
		for (k => v in map) {
			if (filter == null || filter(k, v)) out.push(v);
		}
		return out;
	}

	public static function randomKey<K, V>(map: Map<K, V>, r: hxd.Rand): K {
		var keys = [for (k in map.keys()) k];
		return ArrayExtensions.randomItem(keys, r);
	}

	/**
		Convert a intmap to dynamic
	**/
	public static function toDynamic(map: Map<String, Int>): Dynamic {
		if (map == null) return {};
		final dy: DynamicAccess<Dynamic> = {};
		for (key => value in map) {
			dy.set(key, value);
		}
		return dy;
	}

	public static function stringBoolMaptoDynamic(map: Map<String, Bool>): Dynamic {
		if (map == null) return {};
		final dy: DynamicAccess<Dynamic> = {};
		for (key => value in map) {
			dy.set(key, value);
		}
		return dy;
	}

	public static function loadIntMap(map: Map<String, Int>, data: Dynamic) {
		for (key => value in (data: DynamicAccess<Dynamic>)) {
			if (Std.isOfType(key, String) && Std.isOfType(value, Int)) {
				map[cast key] = cast value;
			}
		}
	}
}
