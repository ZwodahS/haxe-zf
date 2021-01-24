package zf;

class ProbabilityTableIterator<T> {
    var chances: Array<{chance: Int, item: T}>;
    var index = 0;

    public function new(chances: Array<{chance: Int, item: T}>) {
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
    ProbabilityTable stores a mapping of [Chance] -> T
    It then allow for rolling for T by providing a hxd.Rand
**/
class ProbabilityTable<T> {
    var chances: Array<{chance: Int, item: T}>;

    public var totalChance(default, null): Int;

    public var length(get, never): Int;

    public function get_length(): Int {
        return chances.length;
    }

    public function new() {
        this.chances = [];
        this.totalChance = 0;
    }

    public function add(chance: Int, item: T) {
        this.chances.push({chance: chance, item: item});
        this.totalChance += chance;
    }

    public function roll(?r: hxd.Rand): Null<T> {
        if (totalChance == 0) return null;
        var chance = r == null ? Random.int(1, totalChance) : 1 + r.random(totalChance);
        for (c in this.chances) {
            if (chance <= c.chance) return c.item;
            chance -= c.chance;
        }
        return null;
    }

    public function keyValueIterator(): ProbabilityTableIterator<T> {
        return new ProbabilityTableIterator<T>(chances);
    }
}
