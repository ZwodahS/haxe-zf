package zf.math;

/**
	@stage:stable
**/
inline function clamp(num: Int, min: Null<Int>, max: Null<Int>): Int {
	if (min != null && num < min) return min;
	if (max != null && num > max) return max;
	return num;
}

inline function signedString(int: Int) {
	return int > 0 ? '+${int}' : '${int}';
}
