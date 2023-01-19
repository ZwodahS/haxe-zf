package zf.tests;

enum TestCaseState {
	Init;
	Running;
	Completed;
}

private typedef TestStep = {
	public var ?id: String;
	public var ?func: Void->Void;
}

/**
	@stage:unstable

	Generic TestCase class, parent of all the test cases.
**/
class TestCase {
	/**
		A reference to the current runner.
	**/
	public var runner: TestRunner;

	/**
		The current step index.
	**/
	public var ind(default, null): Int = -1;

	/**
		Store all the steps.
	**/
	var steps: Array<TestStep>;

	/**
		Get the next step in the test case and move along the step counter.
	**/
	public var next(get, never): TestStep;

	inline function get_next(): TestStep {
		if (this.ind < this.steps.length) this.ind += 1;
		return this.current;
	}

	/**
		Get the current step without moving the step counter
	**/
	public var current(get, never): TestStep;

	inline function get_current(): TestStep {
		return this.steps.length > this.ind ? this.steps[this.ind] : null;
	}

	public var renderLayers(get, never): h2d.Object;

	public function get_renderLayers(): h2d.Object {
		return null;
	}

	/**
		The id of the test. Can be used to log the test etc.
	**/
	public var testId: String = "";

	/**
		Name of the test case
	**/
	public var name: String = "";

	public var result: TestResult = null;

	public var state(default, set): TestCaseState = Init;

	public function set_state(s: TestCaseState): TestCaseState {
		var prev = this.state;
		this.state = s;
		onStateChanged(prev, s);
		return this.state;
	}

	public function new(testId: String, name: String) {
		this.testId = testId;
		this.name = name;
		this.steps = [];
		this.logs = [];
	}

	/**
		Set up function of the test case.
		This is called just before the test case starts.
	**/
	public function setup() {}

	/**
		This is called by the test runner on each frame.
		This is called regardless if `shouldRunNext()` return true or false.

		Wed 11:42:48 04 Jan 2023
		This is currently only used by WorldTestCase but may have other uses.
	**/
	public function update(dt: Float) {
		if (this.waitDelta > 0) {
			this.waitDelta -= dt;
			if (this.waitDelta < 0) this.waitDelta = 0;
		}
	}

	/**
		Handle events
	**/
	public function onEvent(event: hxd.Event) {}

	/**
		Denote if the test case should move to the next step
	**/
	public function shouldRunNext(): Bool {
		if (this.waitDelta > 0) return false;
		if (this.waitFunc != null && this.waitFunc() == false) return false;
		this.waitFunc = null;
		return true;
	}

	// ---- Test case functions ---- //

	/**
		Run a function as a single step.
	**/
	public function run(id: String = null, func: Void->Void = null) {
		if (func == null) return;
		if (id == null) id = 'Step: ${this.steps.length}';
		this.steps.push({id: id, func: func});
	}

	var waitDelta: Float = 0;

	/**
		Wait for X seconds before moving to the next step.
	**/
	public function wait(id: String = null, w: Float) {
		// if the test case is already running, we don't add it to the steps, we just run it
		if (this.ind != -1) {
			this.waitDelta = w;
		} else {
			this.steps.push({
				id: id == null ? "Wait" : id,
				func: () -> {
					this.waitDelta = w;
				}
			});
		}
	}

	var waitFunc: Void->Bool = null;

	/**
		Wait until a function return true
	**/
	public function waitFor(id: String = null, f: Void->Bool) {
		// if the test case is already running, we don't add it to the steps, we just run it
		if (this.ind != -1) {
			this.waitFunc = f;
		} else {
			this.steps.push({
				id: id == null ? "WaitFor" : id,
				func: () -> {
					this.waitFunc = f;
				}
			});
		}
	}

	// ---- Logging ---- //
	public var logs: Array<LogEntry>;

	inline public function log(level: Int, message: String) {
		final entry: LogEntry = {level: level, message: message};
		this.logs.push(entry);
		onLogAdded(entry);
	}

	inline public function info(message: String) {
		log(0, message);
	}

	inline public function warn(message: String) {
		log(50, message);
	}

	public function exception(e: haxe.Exception, stackItems: Array<haxe.CallStack.StackItem> = null) {
		log(100, 'EXCEPTION');
		log(100, e.message);
		if (stackItems != null) {
			for (s in stackItems) {
				log(99, 'Called from ${Logger.stackItemToString(s)}');
			}
		}
	}

	inline public function error(message: String) {
		log(100, message);
	}

	dynamic public function onLogAdded(logEntry: LogEntry) {}

	dynamic public function onStateChanged(prev: TestCaseState, next: TestCaseState) {}
}

/**
	Wed 11:49:54 04 Jan 2023 Start of tests module
**/
