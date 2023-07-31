package zf.ds;

using zf.RandExtensions;

/**
	@stage:stable
**/
class ArrayExtensions {
	/**
		Fisher-Yates shuffle

		shuffle an array using hxd.Rand

		Reference: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	**/
	public static function shuffle<T>(array: Array<T>, r: hxd.Rand = null) {
		if (array.length <= 1) return;
		if (r == null) {
			r = new hxd.Rand(Random.int(0, zf.Constants.MaxInt32));
		}
		var i = array.length - 1;
		while (i >= 1) {
			// Note: We need to include the index itself.
			var j = r.randomInt(i + 1);
			if (i != j) {
				var t = array[j];
				array[j] = array[i];
				array[i] = t;
			}
			i--;
		}
	}

	public static function hasIntersection<T>(arr1: Array<T>, arr2: Array<T>, minCount = 1): Bool {
		var count = 0;
		for (item1 in arr1) {
			for (item2 in arr2) {
				if (item1 != item2) continue;
				count += 1;
				if (count >= minCount) return true;
			}
		}
		return false;
	}

	/**
		Add the elements in an array to another array, modifying it.
	**/
	inline public static function pushArray<T>(arr: Array<T>, pushedArray: Array<T>) {
		for (i in pushedArray) arr.push(i);
	}

	inline public static function pushItems<T>(arr: Array<T>, item: T, count: Int) {
		for (_ in 0...count) arr.push(item);
	}

	/**
		Find the first item in array that matches a criteria
	**/
	@:deprecated("use find from Lambda instead")
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
		Returns a shallow copy of the array reversed
	**/
	public static function reversed<T>(arr: Array<T>): Array<T> {
		final out: Array<T> = [];
		var i = arr.length - 1;
		while (i >= 0) {
			out.push(arr[i]);
			i -= 1;
		}
		return out;
	}

	/**
		Get a random item from an Array using hxd.Rand
	**/
	public static function randomItem<T>(arr: Array<T>, r: hxd.Rand, pop: Bool = false): Null<T> {
		if (pop == true) return r.randomPopItem(arr);
		return r.randomChoice(arr);
	}

	public static function randomItems<T>(arr: Array<T>, r: hxd.Rand, count: Int, pop: Bool = false): Array<T> {
		if (pop == true) return r.randomPopItems(arr, count);
		return r.randomChoices(arr, count);
	}

	inline public static function first<T>(arr: Array<T>): Null<T> {
		return arr.length == 0 ? null : arr[0];
	}

	inline public static function last<T>(arr: Array<T>): Null<T> {
		return arr.length == 0 ? null : arr[arr.length - 1];
	}

	/**
		Split an array into multiple array with groupSize.
		Return Array of Array<T>
		The first N-1 array will contain `groupSize` elements and last array will contain up to groupSize elements.
	**/
	public static function splitIntoGroups<T>(arr: Array<T>, groupSize: Int): Array<Array<T>> {
		var groups: Array<Array<T>> = [];
		var i = 0;
		while (i < arr.length) {
			var end = i + groupSize;
			if (end > arr.length) end = arr.length;
			final group = arr.slice(i, end);
			groups.push(group);
			i += groupSize;
		}
		return groups;
	}

	public static function isEqual<T>(arr1: Array<T>, arr2: Array<T>): Bool {
		if (arr1.length != arr2.length) return false;
		for (ind in 0...arr1.length) {
			if (arr1[ind] != arr2[ind]) return false;
		}
		return true;
	}
}
