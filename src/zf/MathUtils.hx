package zf;

class MathUtils {
    inline public static function round(number: Float, ?precision = 2): Float {
        number *= Math.pow(10, precision);
        return Math.round(number) / Math.pow(10, precision);
    }

    inline public static function random(min: Int, max: Int): Int {
        // min inclusive, max inclusive
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    inline public static function sign(number: Float): Int {
        return number > 0 ? 1 : number < 0 ? -1 : 0;
    }

    inline public static function clampF(value: Float, min: Null<Float>, max: Null<Float>): Float {
        if (min != null && value < min) return min;
        if (max != null && value > max) return max;
        return value;
    }

    inline public static function clampI(value: Int, min: Null<Int>, max: Null<Int>): Int {
        if (min != null && value < min) return min;
        if (max != null && value > max) return max;
        return value;
    }

    inline public static function distance(x1: Float, y1: Float, x2: Float, y2: Float): Float {
        return hxd.Math.sqrt(hxd.Math.pow(hxd.Math.abs(x1 - x2), 2) + hxd.Math.pow(hxd.Math.abs(y1 - y2), 2));
    }

    inline public static function iMax(ints: Array<Int>): Int {
        var m = ints[0];
        for (i in ints) {
            if (i > m) m = i;
        }
        return m;
    }

    inline public static function iAbs(i: Int): Int {
        return i >= 0 ? i : -i;
    }
}
