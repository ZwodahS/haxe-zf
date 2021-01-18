package zf;

/**
    Extends hxd.Rand to provide additional functionality.
**/
@:forward(random, shuffle, rand, srand)
abstract Rand(hxd.Rand) from hxd.Rand to hxd.Rand {
    public function new(r: hxd.Rand) {
        this = r;
    }

    inline public function randomChoice<T>(a: Array<T>): Null<T> {
        return a.length == 0 ? null : a[this.random(a.length)];
    }

    inline public function randomPop<T>(a: Array<T>): Null<T> {
        if (a.length == 0) return null;
        var pos = this.random(a.length);
        var item = a.splice(pos, 1);
        return item[0];
    }
}
