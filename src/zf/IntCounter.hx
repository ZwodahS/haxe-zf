package zf;

interface IntCounter {
	public function getNextInt(): Int;
}

/**
	@stage:stable
**/
class SimpleIntCounter implements IntCounter {
	public var counter(default, null): Int = 0;

	public function new(startingId: Int = 0) {
		this.counter = startingId;
	}

	public function getNextInt(): Int {
		return counter++;
	}
}
