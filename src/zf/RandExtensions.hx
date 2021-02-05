package zf;

/**
    Extends hxd.Rand to provide additional functionality.
**/
class RandExtensions {
    public static function randomChoice<T>(r: hxd.Rand, a: Array<T>): Null<T> {
        return a.length == 0 ? null : a[r.random(a.length)];
    }

    public static function randomPop<T>(r: hxd.Rand, a: Array<T>): Null<T> {
        if (a.length == 0) return null;
        var pos = r.random(a.length);
        var item = a.splice(pos, 1);
        return item[0];
    }
}
