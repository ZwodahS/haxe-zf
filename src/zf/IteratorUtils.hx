package zf;

/**
	from https://code.haxe.org/category/data-structures/reverse-iterator.html
**/
class ReverseIntIterator {
	var end: Int;
	var i: Int;

	public inline function new(start: Int, end: Int) {
		this.i = start;
		this.end = end;
	}

	public inline function hasNext(): Bool
		return i >= end;

	public inline function next(): Int
		return i--;
}

class IntIterator {
	var end: Int;
	var i: Int;

	public inline function new(start: Int, end: Int) {
		this.i = start;
		this.end = end;
	}

	public inline function hasNext(): Bool
		return i <= end;

	public inline function next(): Int
		return i++;
}

class IteratorUtils {
	/**
		Both start and end are inclusive
	**/
	public static function iterateInt(start: Int, end: Int): Iterator<Int> {
		if (start <= end) {
			return new IntIterator(start, end);
		} else {
			return new ReverseIntIterator(start, end);
		}
	}
}
