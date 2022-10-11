package zf.math;

inline function equals(a: Float, b: Float, diff: Float = 0.00001): Bool {
	return Math.abs(a - b) <= diff;
}

inline function round(num: Float, ?precision = 2): Float {
	num *= Math.pow(10, precision);
	return Math.round(num) / Math.pow(10, precision);
}

inline function clamp(num: Float, min: Null<Float>, max: Null<Float>): Float {
	return Math.clampF(num, min, max);
}

inline function sign(number: Float): Int {
	return number > 0 ? 1 : number < 0 ? -1 : 0;
}
