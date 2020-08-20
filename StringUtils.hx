package common;

class StringUtils {
    inline public static function formatFloat(v: Float, dp: Int = 0): String {
        var str = '${v}';
        var split = str.split('.');
        if (split.length == 1) return split[0];
        return split[0] + '.' + split[1].substring(0, dp);
    }
}
