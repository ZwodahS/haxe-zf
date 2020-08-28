package common;

class AlignmentUtils {
    public inline static function center(offset: Float, total: Float, width: Float): Float {
        return offset + ((total - width) / 2);
    }
}
