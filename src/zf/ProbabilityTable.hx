package zf;

import hxd.Rand;

using zf.ds.ArrayExtensions;

/**
    Probabilty Table allows us to choose object from a list based on their weights
**/
@:structInit class Chance<T> {
    public var chance: Int;
    public var item: T;

    public function new(chance: Int, item: T) {
        this.chance = chance;
        this.item = item;
    }
}

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
            chances.push(c);
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
        this.totalChance = this.chances.reduce(function(i, v) {
            return i.chance + v;
        }, 0);
    }

    @:generic
    static function _random<T>(chances: Array<Chance<T>>, r: Rand, ?totalChance: Null<Int>): Int {
        if (totalChance == null) totalChance = chances.reduce(function(i, v) {
            return i.chance + v;
        }, 0);

        var chance = 1 + r.random(totalChance);
        for (ind => c in chances) {
            if (chance <= c.chance) return ind;
            chance -= c.chance;
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
    public function randomItem(?r: Rand): Null<T> {
        if (totalChance == 0) return null;
        r = r != null ? r : new Rand(Random.int(0, Constants.SeedMax));
        var ind = _random(this.chances, r, this.totalChance);
        return this.chances[ind].item;
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
}
