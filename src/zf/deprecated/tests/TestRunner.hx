package zf.deprecated.tests;

/**
	@stage:deprecating
**/
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

/**
	Thu 14:06:39 05 Jan 2023
	Deprecate this eventually. See zf.tests.TestCase
**/
