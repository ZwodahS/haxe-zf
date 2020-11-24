package zf;

/**
    Extends hxd.Rand to provide additional functionality.
**/
class Rand extends hxd.Rand {
    inline public function randomChoice<T>(a: Array<T>): Null<T> {
        return a.length == 0 ? null : a[this.random(a.length)];
    }
}
