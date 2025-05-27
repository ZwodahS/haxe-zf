package zf.input;

import hxd.Pad;

/**
	Handle controller input like keyboard inputs.
**/
class PadInputMapping {
	var keyMappings: Map<Int, Void->Void>;
	var handlers: Array<{key: Int, func: Void->Void}>;

	/**
		If true, this will handle the left stick input as dpad input with a delay
	**/
	public var handleAxisAsDpad = false;

	/**
		For turn based game, it is better to set this to true.
		This means that only 1 input will be handled per update call.

		Also, in that case the order of handling is by the order of adding.
	**/
	public var singleHandlePerFrame = false;

	/**
		Delay for Axis handled as dpad input
	**/
	public var axisDelay = 0.2;

	var _delay: Float = 0;

	var conf: PadConfig;

	public function new(conf: PadConfig, handleAxisAsDpad: Bool = false, singleHandlePerFrame: Bool = false) {
		this.keyMappings = [];
		this.handlers = [];
		this.conf = conf;
		this.handleAxisAsDpad = handleAxisAsDpad;
		this.singleHandlePerFrame = singleHandlePerFrame;
	}

	public function update(pad: hxd.Pad, dt: Float) {
		if (pad == null) return;

		var handledDpad = false;
		// axis input is always handled first
		if (this.handleAxisAsDpad == true) {
			if (this._delay > 0) this._delay = Math.clampF(this._delay - dt, .0, null);
			if (this._delay <= 0) {
				if (this.keyMappings.exists(this.conf.dpadRight) && pad.xAxis > 0.75) {
					this.keyMappings[this.conf.dpadRight]();
					this._delay = this.axisDelay;
					handledDpad = true;
				} else if (this.keyMappings.exists(this.conf.dpadLeft) && pad.xAxis < -0.75) {
					this.keyMappings[this.conf.dpadLeft]();
					this._delay = this.axisDelay;
					handledDpad = true;
				} else if (this.keyMappings.exists(this.conf.dpadDown) && pad.yAxis > 0.75) {
					this.keyMappings[this.conf.dpadDown]();
					this._delay = this.axisDelay;
					handledDpad = true;
				} else if (this.keyMappings.exists(this.conf.dpadUp) && pad.yAxis < -0.75) {
					this.keyMappings[this.conf.dpadUp]();
					this._delay = this.axisDelay;
					handledDpad = true;
				}
			}
		}

		if (this.singleHandlePerFrame == true && handledDpad == true) return;

		for (handler in this.handlers) {
			if (handledDpad == true
				&& (handler.key == this.conf.dpadRight || handler.key == this.conf.dpadLeft
					|| handler.key == this.conf.dpadUp || handler.key == this.conf.dpadDown)) continue;

			if (pad.isPressed(handler.key) == true) {
				handler.func();
				if (this.singleHandlePerFrame == true) return;
			}
		}
	}

	public function addMapping(key: Int, func: Void->Void) {
		if (this.keyMappings.exists(key) == true) return;
		this.keyMappings.set(key, func);
		this.handlers.push({key: key, func: func});
	}
}
