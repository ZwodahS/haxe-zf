package zf;

import hxd.Rand;

using zf.ds.ArrayExtensions;
using zf.RandExtensions;

using Lambda;

/**
	A linear iterator of all the chances in the table.
	This is returned likely in the ordered that they are added.
**/
class ProbabilityTableIterator<T> {
	var chances: Array<Chance<T>>;
	var index = 0;

	public function new(chances: Array<Chance<T>>) {
		this.chances = chances;
	}

	public function hasNext(): Bool {
		return index < this.chances.length;
	}

	public function next(): {key: Int, value: T} {
		if (!hasNext()) return null;
		var curr = this.chances[this.index];
		this.index++;
		return {key: curr.chance, value: curr.item};
	}
}

/**
	A probabilistic iterator of the table.
	This will randomly return items based on their weightage
**/
class ProbabilityTableRandomIterator<T> {
	var totalChance: Int;
	var chances: Array<Chance<T>>;
	var r: Rand;

	public function new(chances: Array<Chance<T>>, r: Rand) {
		this.totalChance = 0;
		this.chances = [];
		this.r = r;
		for (c in chances) {
			this.chances.push(c);
			totalChance += c.chance;
		}
	}

	public function hasNext(): Bool {
		return this.chances.length > 0 && this.totalChance != 0;
	}

	public function next(): Null<T> {
		if (!hasNext()) return null;
		@:privateAccess var index = ReadOnlyProbabilityTable._random(this.chances, r, this.totalChance);
		var item = chances.splice(index, 1)[0];
		this.totalChance -= item.chance;
		return item.item;
	}
}

/**
	@stage:stable

	The Readonly version of the table.
	Doesn't not guaranteed immutability since the object can be casted
**/
class ReadOnlyProbabilityTable<T> {
	var chances: Array<Chance<T>>;

	public var totalChance(default, null): Int;
	public var length(get, never): Int;

	public function get_length(): Int {
		return chances.length;
	}

	public function new(?chances: Array<Chance<T>>) {
		if (chances == null) chances = [];
		this.chances = chances;
		this.totalChance = this.chances.fold(function(i, v) {
			return i.chance + v;
		}, 0);
	}

	@:generic
	static function _random<T>(chances: Array<Chance<T>>, r: Rand, ?totalChance: Null<Int>): Int {
		if (totalChance == null) totalChance = chances.fold(function(i, v) {
			return i.chance + v;
		}, 0);

		var chance = 1 + r.randomInt(totalChance);
		for (ind => c in chances) {
			if (chance <= c.chance) return ind;
			chance -= c.chance;
		}
		return 0;
	}

	public function getChance(item: T): Int {
		for (c in this.chances) {
			if (c.item == item) return c.chance;
		}
		return 0;
	}

	/**
		An alias to randomItem, deprecated
	**/
	@:deprecated
	public function roll(?r: Rand): Null<T> {
		return randomItem(r);
	}

	/**
		Returns a random item in the table
	**/
	public function randomItem(?r: Rand, remove: Bool = false): Null<T> {
		if (totalChance == 0) return null;
		r = r != null ? r : new Rand(Random.int(0, Constants.SeedMax));
		var ind = _random(this.chances, r, this.totalChance);
		var c = this.chances[ind];
		if (remove) {
			this.chances.splice(ind, 1);
			this.totalChance -= c.chance;
		}
		return c.item;
	}

	/**
		Returns random items from the table
	**/
	public function randomItems(count: Int, ?r: Rand, allowDuplicate: Bool = false): Array<T> {
		r = r != null ? r : new Rand(Random.int(0, Constants.SeedMax));
		// make a copy of both
		var totalChance = this.totalChance;
		var items: Array<Chance<T>> = [for (c in this.chances) c];

		final out: Array<T> = [];
		for (_ in 0...count) {
			if (items.length == 0) break;
			final c = r.randomInt(totalChance);
			final index = _select(items, c);
			final item = items[index];
			out.push(item.item);
			items.splice(index, 1);
			totalChance -= item.chance;
			if (items.length == 0) break;
		}
		return out;
	}

	static function _select<T>(chances: Array<Chance<T>>, chance: Int): Int {
		for (ind => c in chances) {
			if (c.chance == 0) continue;
			if (chance < c.chance) return ind;
			chance -= c.chance;
		}
		return 0;
	}

	/**
		return a randomed Iterator of the item in this table
	**/
	public function randomList(?r: Rand): ProbabilityTableRandomIterator<T> {
		r = r != null ? r : new Rand(Random.int(0, Constants.SeedMax));
		return new ProbabilityTableRandomIterator(this.chances, r);
	}

	public function keyValueIterator(): ProbabilityTableIterator<T> {
		return new ProbabilityTableIterator<T>(chances);
	}

	public function toString(): String {
		return [for (c in this.chances) '${c.chance} => ${c.item}'].join("\n");
	}
}

/**
	ProbabilityTable stores a mapping of [Chance] -> T
	It then allow for rolling for T by providing a Rand
**/
class ProbabilityTable<T> extends ReadOnlyProbabilityTable<T> {
	public function add(chance: Int, item: T) {
		this.chances.push({chance: chance, item: item});
		this.totalChance += chance;
	}

	public function reduce(item: T, amount: Int) {
		for (c in this.chances) {
			if (c.item == item) {
				if (c.chance < amount) amount = c.chance;
				c.chance -= amount;
				if (c.chance == 0) this.chances.remove(c);
				this.totalChance -= amount;
				return;
			}
		}
	}

	public function updateChance(item: T, amount: Int) {
		for (c in this.chances) {
			if (c.item == item) {
				final diff = c.chance - amount;
				if (diff == 0) return;
				if (amount == 0) {
					this.chances.remove(c);
				} else {
					c.chance = amount;
				}
				this.totalChance -= diff;
				return;
			}
		}
	}

	public function remove(item: T): Bool {
		var i = -1;
		for (ind => c in this.chances) {
			if (c.item == item) {
				i = ind;
				break;
			}
		}
		if (i == -1) return false;
		final chance = this.chances[i];
		this.chances.splice(i, 1);
		this.totalChance -= chance.chance;
		return true;
	}

	/**
		Make a copy of this probability table
	**/
	public function copy(): ProbabilityTable<T> {
		return new zf.ProbabilityTable<T>(this.toList());
	}

	/**
		Return a list of chance representing the probability table.
		The chances are shallow-copied
	**/
	public function toList(): Array<Chance<T>> {
		final chances: Array<Chance<T>> = [];
		for (c in this.chances) {
			chances.push(c.copy());
		}
		return chances;
	}

	/**
		create a prob table from chances, such that the value returns is the index of the array
	**/
	public static function fromChances(chances: Array<Int>): ReadOnlyProbabilityTable<Int> {
		var tb = new ProbabilityTable<Int>();
		for (ind => c in chances) tb.add(c, ind);
		return tb;
	}
}
