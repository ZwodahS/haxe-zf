package zf.ds;

/**
	Iterate 2 arrays at once.

	This will iterate until both array are fully iterated.
	If the length is different then the shorter one will return null
**/
class ArrayPairIterator<E1, E2> {
	var arr1: Array<E1>;
	var arr2: Array<E2>;
	var ind: Int = 0;

	public function new(arr1: Array<E1>, arr2: Array<E2>) {
		this.arr1 = arr1;
		this.arr2 = arr2;
	}

	public function hasNext(): Bool {
		return this.ind < arr1.length || this.ind < arr2.length;
	}

	public function next(): {key: Null<E1>, value: Null<E2>} {
		if (hasNext() == false) return null;
		final k = this.arr1.length <= this.ind ? null : this.arr1[this.ind];
		final v = this.arr2.length <= this.ind ? null : this.arr2[this.ind];
		this.ind++;
		return {key: k, value: v};
	}
}
