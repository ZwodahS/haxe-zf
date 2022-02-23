package zf;

import hxd.Rand;

using zf.RandExtensions;

/**
	A simple "chance" object, that allow you to store a data and attach a chance to it.

	Tue 12:38:34 22 Feb 2022
	This is previously used by ProbabilityTable only, but since it is actually quite useful
	to have a data structure like this, we will move it out.

	There are are 2 ways to interpret chance / weight since they are the same thing
	or can means different thing when used in different context.

	When Chance is used alone, chance literally means chance to happen.
	This is the interpretation when roll() is used.

	When used in Probability table, the chance more or less means weight and roll() method
	is not used.
**/
@:structInit class Chance<T> {
	public var chance: Int;
	public var item: T;

	public function new(chance: Int, item: T) {
		this.chance = chance;
		this.item = item;
	}

	inline public function roll(r: hxd.Rand, base: Int = 100): Bool {
		return r.randomChance(this.chance, base);
	}
}
