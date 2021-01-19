package zf;

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
}
