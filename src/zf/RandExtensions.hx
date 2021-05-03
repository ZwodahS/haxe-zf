package zf;

/**
	Extends hxd.Rand to provide additional functionality.
**/
class RandExtensions {
	public static function randomChoice<T>(r: hxd.Rand, a: Array<T>): Null<T> {
		return a.length == 0 ? null : a[r.random(a.length)];
	}

	public static function randomChoices<T>(r: hxd.Rand, a: Array<T>, count: Int): Array<T> {
		var choices = [for (i in 0...a.length) i];
		var out: Array<T> = [];
		for (i in 0...count) {
			var choice = randomChoice(r, choices);
			choices.remove(choice);
			out.push(a[choice]);
			if (choices.length == 0) break;
		}
		return out;
	}

	public static function randomPop<T>(r: hxd.Rand, a: Array<T>): Null<T> {
		if (a.length == 0) return null;
		var pos = r.random(a.length);
		var item = a.splice(pos, 1);
		return item[0];
	}

	public static function randomWithinRange(r: hxd.Rand, min: Int, max: Int): Int {
		if (max == min) return min;
		var diff = max - min + 1;
		return r.random(diff) + min;
	}

	public static function randomChance(r: hxd.Rand, chance: Int, base: Int = 100): Bool {
		if (chance >= base) return true;
		return r.random(base) < chance;
	}
}
