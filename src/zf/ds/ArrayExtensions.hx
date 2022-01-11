package zf.ds;

using zf.RandExtensions;

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

	/**
		shuffle an array using hxd.Rand
	**/
	public static function shuffle<T>(array: Array<T>, r: hxd.Rand = null) {
		if (array.length <= 1) return;
		if (r == null) {
			r = new hxd.Rand(Random.int(0, zf.Constants.MaxInt32));
		}
		var i = array.length - 1;
		while (i >= 1) {
			var j = r.randomInt(i);
			if (i != j) {
				var t = array[j];
				array[j] = array[i];
				array[i] = t;
			}
			i--;
		}
	}

	/**
		Add the elements in an array to another array, modifying it.
	**/
	inline public static function pushArray<T>(arr: Array<T>, pushedArray: Array<T>) {
		for (i in pushedArray) arr.push(i);
	}

	/**
		Find the first item in array that matches a criteria
	**/
	public static function findOne<T>(arr: Array<T>, func: T->Bool): Null<T> {
		for (i in arr) {
			if (func(i)) return i;
		}
		return null;
	}

	/**
		Remove all item in an array
	**/
	inline public static function clear<T>(arr: Array<T>) {
		arr.resize(0);
	}

	/**
		A smart index.
		negative value will return arr[.length + ind]
		positive value(including 0) will return arr[ind];
		if out of bound, return null
	**/
	inline public static function item<T>(arr: Array<T>, index: Int): Null<T> {
		final actualIndex = index >= 0 ? index : arr.length + index;
		if (actualIndex < 0 || actualIndex >= arr.length) return null;
		return arr[actualIndex];
	}

	/**
		Filter and remove items in array that matches a criteria

		Note: This might be slow in cases where many elements are being removed.
		In those cases, constructing a new array with filter might be better.
	**/
	public static function filterAndRemove<T>(arr: Array<T>, func: T->Bool): Array<T> {
		// this might be slow for big array, so need be better to use the default filter to get a new array instead.
		var removed: Array<T> = [];
		var i = 0;
		while (i < arr.length) {
			if (func(arr[i])) {
				removed.push(arr[i]);
				arr.splice(i, 1);
				continue;
			}
			i += 1;
		}
		return removed;
	}

	/**
		Get a random item from an Array using hxd.Rand
	**/
	public static function randomItem<T>(arr: Array<T>, r: hxd.Rand, pop: Bool = false): Null<T> {
		if (pop) return r.randomPop(arr);
		return r.randomChoice(arr);
	}

	inline public static function first<T>(arr: Array<T>): Null<T> {
		return arr.length == 0 ? null : arr[0];
	}

	inline public static function last<T>(arr: Array<T>): Null<T> {
		return arr.length == 0 ? null : arr[arr.length - 1];
	}

	public static function isEqual<T>(arr1: Array<T>, arr2: Array<T>): Bool {
		if (arr1.length != arr2.length) return false;
		for (ind in 0...arr1.length) {
			if (arr1[ind] != arr2[ind]) return false;
		}
		return true;
	}
}
