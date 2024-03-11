package zf.sm;

/**
	@stage:stable

	StateManager and State manages state and handle when state transition happens.
**/
class StateManager {
	public var states: Map<String, State>;

	public var current(default, null): State;

	public function new() {
		this.states = new Map<String, State>();
	}

	public function update(dt: Float) {
		if (this.current != null) this.current.update(dt);

		// handle the transition
		if (this.current != null) {
			final nextState = this.current.getNextState();
			if (nextState != null) {
				switchState(nextState);
			}
		}
	}

	function switchState(nextState: State) {
		final previous = this.current;
		if (this.current != null) this.current.onStateExit();
		this.current = nextState;
		this.current.onStateEnter();
		final next = nextState;
		this.onStateChanged(previous, next);
	}

	dynamic public function onStateChanged(previous: State, next: State) {}

	public function registerState(state: State): State {
		this.states[state.name] = state;
		state.manager = this;
		return state;
	}

	/**
		Check of the current state is a specific state.
	**/
	public function is(s: String = null, ss: Array<String> = null): Bool {
		if (this.current == null) return false;
		if (s != null && this.current.name == s) return true;
		if (ss != null && ss.contains(this.current.name)) return true;
		return false;
	}

	public function get(name: String): State {
		if (this.states[name] == null) return null;
		final state = this.states[name].copy();
		state.manager = this;
		return state;
	}

	public function set(name: String): State {
		if (this.states[name] == null) return null;
		final state = this.states[name].copy();
		state.manager = this;
		switchState(state);
		return state;
	}
}

/**
	Fri 13:58:44 20 Jan 2023

	Motivation:

	Previously I always have a GameState that handles the different state.
	Moving forward, instead of using a enum, we will be using StateManager instead

	This is usually needed for turn based games, not sure about real time game yet.
**/
