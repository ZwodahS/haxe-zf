package common;

/**
    Probability Map stores a mapping of [Chance] -> T
    It then allow for rolling for T by providing a hxd.Rand
**/

class ProbabilityMap<T> {

    var chances: Array<{chance: Int, item: T}>;
    var total: Int;
    public function new() {
        this.chances = [];
        this.total = 0;
    }

    public function add(chance: Int, item: T) {
        this.chances.push({chance: chance, item: item});
        this.total += chance;
    }

    public function roll(?r: hxd.Rand): Null<T> {
        if (total == 0) return null;
        var chance = r == null ? Random.int(1, total) : 1 + r.random(total);
        for (c in this.chances) {
            if (chance <= c.chance) return c.item;
            chance -= c.chance;
        }
        return null;
    }
}
