package zf.sm;

/**
	@stage:stable
**/
class State {
	/**
		The manager handles this state
	**/
	public var manager: StateManager;

	/**
		The name of the state
	**/
	public var name: String;

	public function new(name: String) {
		this.name = name;
	}

	public function update(dt: Float) {}

	/**
		Return the next state.
		If this returns a non-null, the state will be changed.
	**/
	dynamic public function getNextState(): State {
		return null;
	}

	dynamic public function onStateExit() {}

	dynamic public function onStateEnter() {}

	/**
		Return a copy of this state.
		Child class should override this.
	**/
	public function copy(): State {
		return new State(this.name);
	}

	public function dispose() {}

	/**
		Check if this state is of a name
	**/
	public function is(name: String): Bool {
		return this.name == name;
	}

	public function toString(): String {
		return '[State:${name}]';
	}
}
