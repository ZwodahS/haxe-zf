package zf.sm;

/**
	@stage:unstable
**/
class State {
	public var name: String;

	public function new(name: String) {
		this.name = name;
	}

	public function update(dt: Float) {}

	dynamic public function getNextState(): State {
		return null;
	}

	dynamic public function onStateExit() {}

	dynamic public function onStateEnter() {}

	public function copy(): State {
		return new State(this.name);
	}

	public function is(name: String): Bool {
		return this.name == name;
	}
}
