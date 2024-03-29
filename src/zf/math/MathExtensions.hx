package zf.math;

/**
	@stage:stable
**/
function round(cls: Class<Math>, number: Float, ?precision = 2): Float {
	number *= Math.pow(10, precision);
	return Math.round(number) / Math.pow(10, precision);
}

function random(cls: Class<Math>, min: Int, max: Int): Int {
	// min inclusive, max inclusive
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function sign(cls: Class<Math>, number: Float): Int {
	return number > 0 ? 1 : number < 0 ? -1 : 0;
}

function clampF(cls: Class<Math>, value: Float, min: Null<Float>, max: Null<Float>): Float {
	if (min != null && value < min) return min;
	if (max != null && value > max) return max;
	return value;
}

/**
	Clamp value within a range

	@param value the value to be clamped
	@param min the minimum value allowed (inclusive)
	@param max the maximum value allowed (inclusive)
**/
function clampI(cls: Class<Math>, value: Int, min: Null<Int>, max: Null<Int>): Int {
	if (min != null && value < min) return min;
	if (max != null && value > max) return max;
	return value;
}

/**
	Wrap an integer

	@param value the value to wrap
	@param base the base of the interger, i.e. the result will be value % base
**/
function wrapI(cls: Class<Math>, value: Int, base: Int): Int {
	while (value < 0) {
		value += base;
	}
	if (value >= base) value = value % base;
	return value;
}

function distance(cls: Class<Math>, x1: Float, y1: Float, x2: Float, y2: Float): Float {
	return hxd.Math.sqrt(hxd.Math.pow(hxd.Math.abs(x1 - x2), 2) + hxd.Math.pow(hxd.Math.abs(y1 - y2), 2));
}

function iMin(cls: Class<Math>, ints: Array<Int>): Int {
	var m = ints[0];
	for (i in ints) {
		if (i < m) m = i;
	}
	return m;
}

function iMax(cls: Class<Math>, ints: Array<Int>): Int {
	var m = ints[0];
	for (i in ints) {
		if (i > m) m = i;
	}
	return m;
}

function fMin(cls: Class<Math>, floats: Array<Float>): Float {
	var m = floats[0];
	for (f in floats) {
		if (f < m) m = f;
	}
	return m;
}

function fMax(cls: Class<Math>, floats: Array<Float>): Float {
	var m = floats[0];
	for (f in floats) {
		if (f > m) m = f;
	}
	return m;
}

function iAbs(cls: Class<Math>, i: Int): Int {
	return i >= 0 ? i : -i;
}

function increaseAbsoluteValue(cls: Class<Math>, v: Float, amt: Float): Float {
	return v >= 0 ? v + amt : v - amt;
}

function decreaseAbsoluteValue(cls: Class<Math>, v: Float, amt: Float, wrap: Bool = false): Float {
	var newValue = v >= 0 ? v - amt : v + amt;
	if (v >= 0) {
		if (newValue >= 0) return newValue;
		if (!wrap) return 0;
		return newValue;
	} else {
		if (newValue < 0) return newValue;
		if (!wrap) return 0;
		return newValue;
	}
}

function mediumInt(cls: Class<Math>, arr: Array<Int>): Float {
	if (arr.length == 0) return 0;
	if (arr.length % 2 == 0) {
		var m = Std.int(arr.length / 2);
		return ((arr[m] + arr[m - 1]) * 1.0 / 2);
	} else {
		var m = Std.int(arr.length / 2);
		return arr[m] * 1.0;
	}
}

function averageInt(cls: Class<Math>, arr: Array<Int>): Float {
	var total = 0;
	for (i in arr) total += i;
	return total / arr.length;
}

/**
	Not to be used in production. Might have bug
**/
function percentile(cls: Class<Math>, arr: Array<Int>, p: Int): Float {
	final percent = p / 100;
	var position = percent * (arr.length);
	var left = position % 1;
	var right = 1 - left;
	var p = Std.int(position);
	trace(position, p, left, right);
	if (left == 0) {
		return arr[p];
	}
	final v1 = arr[p];
	final v2 = arr[p + 1];
	return left * v1 + right * v2;
}

function statisticInt(cls: Class<Math>, arr: Array<Int>): {
	medium: Float,
	average: Float,
	min: Int,
	max: Int,
} {
	arr.sort((x, y) -> {
		return x - y;
	});
	final stats = {
		medium: MathExtensions.mediumInt(cls, arr),
		average: MathExtensions.averageInt(cls, arr),
		min: arr.length == 0 ? 0 : arr[0],
		max: arr.length == 0 ? 0 : arr[arr.length - 1],
	}
	return stats;
}
