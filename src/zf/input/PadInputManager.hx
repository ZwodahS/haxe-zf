package zf.input;

/**
	@stage:unstable
**/
class PadInputManager {
	public var current(get, never): PadInputState;

	inline public function get_current(): PadInputState {
		return this.stack.length == 0 ? null : this.stack.last();
	}

	public var stack: Array<PadInputState>;

	public var pad(default, set): Pad;

	public function set_pad(v: Pad): Pad {
		this.pad = v;
		for (s in this.stack) s.pad = this.pad;
		return this.pad;
	}

	public function new() {
		this.stack = [];
	}

	public function init(initialState: PadInputState) {
		this.stack.push(initialState);
		initialState.manager = this;
		initialState.pad = this.pad;
		initialState.onEnter(true);
	}

	public function update(dt: Float) {
		if (this.pad != null && this.pad.connected == false) this.pad = null;
		if (this.pad == null) return;

		if (this.current != null) this.current.update(dt);
	}

	/**
		Pop a state and return the new current state
	**/
	public function popState(): PadInputState {
		if (this.stack.length == 1) return this.stack[0];
		final state = this.stack.pop();
		state.onExit(false);
		final newState = this.stack.last();
		newState.onEnter(false);
		return newState;
	}

	public function pushState(state: PadInputState) {
		final state = this.stack.last();
		if (state != null) state.onExit(true);
		this.stack.push(state);
		state.manager = this;
		state.pad = this.pad;
		state.onEnter(true);
		return state;
	}
}
