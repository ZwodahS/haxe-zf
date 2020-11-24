package zf;

class ListUtils {
    // this uses Array utils shuffle
    public static function shuffle<T>(list: List<T>, random: hxd.Rand = null) {
        var arr = [for (item in list) item];
        ArrayUtils.shuffle(arr);
        list.clear();
        for (item in arr) list.push(item);
    }

    public static function contains<T>(list: List<T>, item: T): Bool {
        for (i in list) {
            if (i == item) return true;
        }
        return false;
    }
}
