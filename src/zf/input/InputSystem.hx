package zf.input;

class InputSystem {
	/**
		Track the current input mode.
		This should only be used for single player game
	**/
	public var inputMode: InputMode = KBM;

	public var connectedPad(default, set): hxd.Pad;

	public function set_connectedPad(v: hxd.Pad): hxd.Pad {
		this.connectedPad = v;
		if (this.connectedPad == null) {
			switchToKBM();
		} else {
			switchToController();
		}
		return this.connectedPad;
	}

	public var dispatcher: zf.MessageDispatcher;

	public function new(dispatcher: zf.MessageDispatcher = null) {
		this.dispatcher = dispatcher;
	}

	public function update(dt: Float) {
		if (this.connectedPad != null) {
			// Perhaps we need to watch any button press to switch to controller but that's
			// a bit too much, so we will listen to 2 specific key (A) or (Start)
			if (this.connectedPad.isPressed(this.connectedPad.config.A) == true
				|| this.connectedPad.isPressed(this.connectedPad.config.start) == true) {
				switchToController();
			}
		}
	}

	public function onEvent(e: hxd.Event): Bool {
		if (this.inputMode == Controller && e.kind == hxd.Event.EventKind.EKeyDown) {
			// if we press any key on keyboard while on controller, we will switch to kBM
			switchToKBM();
			return true;
		}
		return false;
	}

	function switchToKBM() {
		if (this.inputMode == KBM) return;
		this.inputMode = KBM;
		if (this.dispatcher != null) this.dispatcher.dispatch(MOnInputModeChanged.alloc(KBM)).dispose();
	}

	function switchToController() {
		if (this.inputMode == Controller) return;
		this.inputMode = Controller;
		if (this.dispatcher != null) this.dispatcher.dispatch(MOnInputModeChanged.alloc(Controller)).dispose();
	}
}
