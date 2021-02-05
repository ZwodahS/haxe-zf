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
}
