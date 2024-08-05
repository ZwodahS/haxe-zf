package zf.ds;

/**
	Iterator for multiple arrays
**/
class ArrayArrayIterator<E> {
	var a: Int = 0;
	var i: Int = 0;

	var arr: Array<Array<E>>;

	public function new(arr: Array<Array<E>>) {
		this.arr = arr;
	}

	public function hasNext(): Bool {
		return a < this.arr.length && i < this.arr[a].length;
	}

	public function next(): Null<E> {
		if (hasNext() == false) return null;
		final item = arr[a][i++];
		if (i >= this.arr[a].length) {
			i = 0;
			a += 1;
		}
		return item;
	}
}
