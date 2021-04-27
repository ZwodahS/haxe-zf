package zf;

/**
	Color will be immutable, so all method will return a new instance of Color

	Methods will be added when needed
**/
abstract Color(Int) from Int to Int {
	public function new(i: Int) {
		this = i;
	}
}
