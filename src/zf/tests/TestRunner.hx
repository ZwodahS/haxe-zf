package zf.tests;

class TestRunner {
	var cases: List<TestCase>;

	public function new() {
		this.cases = new List<TestCase>();
	}

	public function add(tc: TestCase) {
		this.cases.add(tc);
	}

	public function run() {
		for (tc in this.cases) {
			tc.run();
		}
	}
}
