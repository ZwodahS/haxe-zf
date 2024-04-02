package zf;

/**
	@stage:stable

	Extends hxd.Rand to provide additional functionality.
**/
class RandExtensions {
	public static function randomChoice<T>(r: hxd.Rand, a: Array<T>): Null<T> {
		return a.length == 0 ? null : a.length == 1 ? a[0] : a[r.random(a.length)];
	}

	public static function randomChoices<T>(r: hxd.Rand, a: Array<T>, count: Int): Array<T> {
		var choices = [for (i in 0...a.length) i];
		var out: Array<T> = [];
		if (choices.length == 0) return out;
		for (i in 0...count) {
			var choice = randomChoice(r, choices);
			choices.remove(choice);
			out.push(a[choice]);
			if (choices.length == 0) break;
		}
		return out;
	}

	@:deprecated
	public static function randomPop<T>(r: hxd.Rand, a: Array<T>): Null<T> {
		return randomPopItem(r, a);
	}

	public static function randomPopItem<T>(r: hxd.Rand, a: Array<T>): Null<T> {
		if (a.length == 0) return null;
		var pos = r.random(a.length);
		var item = a.splice(pos, 1);
		return item[0];
	}

	public static function randomPopItems<T>(r: hxd.Rand, a: Array<T>, count: Int): Array<T> {
		final out: Array<T> = [];
		for (_ in 0...count) {
			final o = randomPopItem(r, a);
			if (o != null) out.push(o);
			if (a.length == 0) break;
		}
		return out;
	}

	/**
		Return a random integer between min and max (inclusive)
	**/
	public static function randomWithinRange(r: hxd.Rand, min: Int, max: Int): Int {
		if (max == min) return min;
		var diff = max - min + 1;
		return randomInt(r, diff) + min;
	}

	public static function randomChance(r: hxd.Rand, chance: Int, base: Int = 100): Bool {
		if (chance >= base) return true;
		if (chance == 0) return false;
		return randomInt(r, base) < chance;
	}

	public static function randomWeightedIndex(r: hxd.Rand, weights: Array<Int>): Int {
		// delegate to prob table
		return ProbabilityTable.fromChances(weights).randomItem(r);
	}

	/**
		This is the same as r.random, except that it does checks for max == 0.
		In JS x%0 is undefined, while in hl x%0 == 0
	**/
	inline public static function randomInt(r: hxd.Rand, max: Int): Int {
		return max <= 0 ? 0 : r.random(max);
	}

	/**
		This is the same as r.random, except that it does checks for max == 0.
		In JS x%0 is undefined, while in hl x%0 == 0
	**/
	inline public static function randomIntMax(r: hxd.Rand): Int {
		return randomInt(r, zf.Constants.SeedMax);
	}
}
