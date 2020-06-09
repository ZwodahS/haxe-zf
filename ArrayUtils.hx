package common;

class ArrayUtils {
    // - https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    public static function shuffle<T>(array: Array<T>, random: hxd.Rand = null) {
        if (random == null) {
            random = new hxd.Rand(Random.int(0, 100000));
        }
        if (array.length <= 1) return;
        var i = array.length - 1;
        while (i >= 1) {
            var j = random.random(i);
            if (i != j) {
                var t = array[j];
                array[j] = array[i];
                array[i] = t;
            }
            i--;
        }
    }
}
