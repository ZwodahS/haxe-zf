package zf.ds;

class ArrayExtensions {
	/**
		wrapper to Lambda fold
	**/
	inline public static function fold<T, V>(array: Array<T>, f: (t: T, v: V) -> V, start: V): V {
		return Lambda.fold(array, f, start);
	}

	/**
		wrapper to Lambda fold
	**/
	inline public static function reduce<T, V>(array: Array<T>, f: (t: T, v: V) -> V, start: V): V {
		return Lambda.fold(array, f, start);
	}

	public static function shuffle<T>(array: Array<T>, r: hxd.Rand = null) {
		if (r == null) {
			r = new hxd.Rand(Random.int(0, 100000));
		}
		if (array.length <= 1) return;
		var i = array.length - 1;
		while (i >= 1) {
			var j = r.random(i);
			if (i != j) {
				var t = array[j];
				array[j] = array[i];
				array[i] = t;
			}
			i--;
		}
	}

	public static function pushArray<T>(arr: Array<T>, pushedArray: Array<T>) {
		for (i in pushedArray) arr.push(i);
	}

	public static function findOne<T>(arr: Array<T>, func: T->Bool): Null<T> {
		for (i in arr) {
			if (func(i)) return i;
		}
		return null;
	}

	inline public static function clear<T>(arr: Array<T>) {
		arr.resize(0);
	}
}
