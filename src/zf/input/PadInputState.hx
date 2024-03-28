package zf.input;

/**
	@stage:unstable
**/
class PadInputState {
	public var id: String;

	public var pad: Pad;

	public var navNode: PadInputNavNode;

	public var manager: PadInputManager;

	public function new() {}

	public function update(dt: Float) {
		/**
			Safety check
		**/
		if (this.pad.connected == false) this.pad = null;
		if (this.pad == null) return;
	}

	/**
		Called when the state exits

		@param isOnStack denote if the state is still on the stack
	**/
	public function onExit(isOnStack: Bool) {}

	/**
		Called when the state enters
		@param isNew denote if the state has just enter the stack
	**/
	public function onEnter(isNew: Bool) {}
}
