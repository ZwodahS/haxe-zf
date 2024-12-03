package zf.input;

@:unstable class KeyboardInputMapping {

	var onDownMappings: Map<Int, Void->Void>;
	var onHoldMappings: Map<Int, Float->Void>;
	var onReleasedMappings: Map<Int, Void->Void>;
	var keyDown: Map<Int, Float>;

	public function new() {
		this.onDownMappings = [];
		this.onHoldMappings = [];
		this.onReleasedMappings = [];
		this.keyDown = [];
	}

	public function addMapping(key: Int, onDown: Void->Void, ?onHold: Float->Void, ?onReleased: Void->Void) {
		if (onDown != null) this.onDownMappings[key] = onDown;
		if (onHold != null) this.onHoldMappings[key] = onHold;
		if (onReleased != null) this.onReleasedMappings[key] = onReleased;
	}

	public function removeMapping(key: Int) {
		if (this.onDownMappings[key] == null) return;
		this.onDownMappings.remove(key);
	}

	public function handleEvent(event: hxd.Event): Bool {
		if (event.kind == hxd.Event.EventKind.EKeyDown) {
			final f = this.onDownMappings[event.keyCode];
			if (this.onHoldMappings[event.keyCode] != null) {
				this.keyDown[event.keyCode] = 0;
			}
			if (f != null) f();
			return f != null;
		} else if (event.kind == hxd.Event.EventKind.EKeyUp) {
			final f = this.onReleasedMappings[event.keyCode];
			this.keyDown.remove(event.keyCode);
			if (f != null) f();
			return f != null;
		}
		return false;
	}

	public function update(dt: Float) {
		for (key => holdDuration in this.keyDown) {
			this.keyDown[key] += dt;
			final f = this.onHoldMappings[key];
			if (f != null) f(this.keyDown[key]);
		}
	}
}
