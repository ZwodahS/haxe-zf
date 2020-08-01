package common;

class Strings {
    inline public static function formatFloat(v: Float, dp: Int = 0): String {
        var str = '${v}';
        var split = str.split('.');
        return split[0] + '.' + split[1].substring(0, dp);
    }
}
