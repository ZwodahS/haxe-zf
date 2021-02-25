package zf;

class AlignmentUtils {
	public inline static function center(offset: Float, totalWidth: Float, width: Float): Float {
		return offset + ((totalWidth - width) / 2);
	}
}
