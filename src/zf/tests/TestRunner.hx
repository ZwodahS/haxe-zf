package zf.tests;

import zf.exceptions.AssertionFail;

/**
	@stage:unstable

	A generic test runner for test cases
**/
class TestRunner {
	/**
		Store the current test case
	**/
	public var current(default, null): TestCase;

	public function new() {}

	public function runTest(test: TestCase) {
		Logger.info('runtest: ${test.testId} ${test.name}');
		if (this.current != null) {
			Logger.warn("Can't start test when there is a test running.");
			return;
		}
		this.current = test;
		test.runner = this;

		this.current.state = Running;
		setupTest(test);
	}

	public function update(dt: Float) {
		if (this.current == null) return;

		// run update on the test case
		try {
			this.current.update(dt);
		} catch (e) {
			final stackItems = haxe.CallStack.exceptionStack();
			this.current.exception(e, stackItems);
			Logger.exception(e);
			this.current.error('Exception !!');
			this.current.error('${e}');
			@:privateAccess testcaseComplete({
				success: false,
				failure: 'EXCEPTION',
				stackItems: stackItems,
				exception: e,
				step: this.current.ind,
				stepId: this.current.ind < 0 ? null : this.current.steps[this.current.ind].id,
			});
			return;
		}

		if (this.current.shouldRunNext() == false) return;

		// run the next step in the test case
		final nextStep = this.current.next;
		if (nextStep == null) {
			testcaseComplete({success: true});
			return;
		}

		try {
			this.current.info('---- Step: ${this.current.ind} ----');
			nextStep.func();
		} catch (e: AssertionFail) {
			this.current.warn('Assertion Fail');
			this.current.warn('${e.toString()}');
			testcaseComplete({
				success: false,
				failure: e.toString(),
				step: this.current.ind,
				stepId: nextStep.id,
			});
		} catch (e) {
			final stackItems = haxe.CallStack.exceptionStack();
			this.current.exception(e, stackItems);
			testcaseComplete({
				success: false,
				failure: 'EXCEPTION',
				stackItems: stackItems,
				exception: e,
				step: this.current.ind,
				stepId: nextStep.id,
			});
		}
	}

	function testcaseComplete(testResult: TestResult) {
		this.onTestCaseCompleted(this.current, testResult);
		this.current.runner = null;
		this.current.result = testResult;
		this.current.state = Completed;
		this.current = null;
	}

	public function onUpdateException(e: haxe.Exception, stackItems: Array<haxe.CallStack.StackItem>) {
		@:privateAccess testcaseComplete({
			success: false,
			failure: 'EXCEPTION',
			stackItems: stackItems,
			exception: e,
			step: this.current.ind,
			stepId: this.current.steps[this.current.ind].id,
		});
	}

	/**
		Set up the test.
		Can be overriden to provide more functionalities.
	**/
	public function setupTest(test: TestCase) {
		try {
			test.setup();
		} catch (e) {
			final stackItems = haxe.CallStack.exceptionStack();
			this.current.exception(e, stackItems);
			testcaseComplete({
				success: false,
				failure: 'EXCEPTION',
				stackItems: stackItems,
				exception: e,
				step: -1,
				stepId: 'Setup',
			});
		}
	}

	public function onEvent(event: hxd.Event) {
		if (this.current != null) {
			try {
				this.current.onEvent(event);
			} catch (e) {
				this.current.exception(e, haxe.CallStack.exceptionStack());
				Logger.exception(e);
			}
		}
	}

	dynamic public function onTestCaseCompleted(test: TestCase, testResult: TestResult) {}
}

/**
	Wed 11:49:54 04 Jan 2023 Start of tests module
	Wed 12:19:28 04 Jan 2023
	This is previously named "TestSystem" and is injected into World.
	This creates a dependency that I don't really want.
	This should now be a better way to do things.
**/
