package tests;

import zf.exceptions.AssertionFail;

/**
	TestRunner mainly used for running tests in the commandline and for zf
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
			try {
				tc.run();
				haxe.Log.trace('${tc.name} Passed.', null);
			} catch (e: AssertionFail) {
				haxe.Log.trace("Assertion Fail", null);
				haxe.Log.trace(e.toString(), null);
			}
		}
	}
}
