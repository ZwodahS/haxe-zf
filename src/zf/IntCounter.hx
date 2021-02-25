package zf;

interface IntCounter {
	public function getNextInt(): Int;
}

class SimpleIntCounter implements IntCounter {
	var counter: Int = 0;

	public function new(startingId: Int = 0) {
		this.counter = startingId;
	}

	public function getNextInt(): Int {
		return counter++;
	}
}
