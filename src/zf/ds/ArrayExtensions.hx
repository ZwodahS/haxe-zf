package zf.ds;

class ArrayExtensions {
    /**
        wrapper to Lambda fold
    **/
    inline public static function fold<T, V>(array: Array<T>, f: (t: T, v: V) -> V, start: V): V {
        return Lambda.fold(array, f, start);
    }

    /**
        wrapper to Lambda fold
    **/
    inline public static function reduce<T, V>(array: Array<T>, f: (t: T, v: V) -> V, start: V): V {
        return Lambda.fold(array, f, start);
    }

    public static function shuffle<T>(array: Array<T>, r: hxd.Rand = null) {
        if (r == null) {
            r = new hxd.Rand(Random.int(0, 100000));
        }
        if (array.length <= 1) return;
        var i = array.length - 1;
        while (i >= 1) {
            var j = r.random(i);
            if (i != j) {
                var t = array[j];
                array[j] = array[i];
                array[i] = t;
            }
            i--;
        }
    }
}
