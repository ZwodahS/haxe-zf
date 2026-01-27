package zf.input;

import hxd.Pad;

typedef PadHandler = {
	public var key: Int;
	public var func: Void->Void;
	public var holdDelay: Float;
	public var hold: Float; // the elapsed time the button is held.
	public var repeat: Bool; // if repeat is true, then the func will be called repeatly.

	public var isDown: Bool;
}

class PadInputMapping {
	var handlers: Map<Int, PadHandler>;

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

	var _axisDelay: Float = 0;

	var conf: PadConfig;
	public function new(conf: PadConfig, handleAxisAsDpad: Bool = false, singleHandlePerFrame: Bool = false) {
		this.handlers = [];
		this.conf = conf;
		this.handleAxisAsDpad = handleAxisAsDpad;
		this.singleHandlePerFrame = singleHandlePerFrame;
	}

	public function update(pad: hxd.Pad, dt: Float) {
		if (pad == null) return;

		for (_ => handler in this.handlers) handler.isDown = false;

		var handledDpad = false;
		// axis input is always handled first, since you can only be in one of them at once.
		if (this.handleAxisAsDpad == true) {
			if (this._axisDelay > 0) this._axisDelay = Math.clampF(this._axisDelay - dt, .0, null);
			if (this._axisDelay <= 0) {
				if (this.handlers.exists(this.conf.dpadRight) && pad.xAxis > 0.75) {
					this.handlers[this.conf.dpadRight].isDown = true;
					this._axisDelay = this.axisDelay;
					handledDpad = true;
				} else if (this.handlers.exists(this.conf.dpadLeft) && pad.xAxis < -0.75) {
					this.handlers[this.conf.dpadLeft].isDown = true;
					this._axisDelay = this.axisDelay;
					handledDpad = true;
				} else if (this.handlers.exists(this.conf.dpadDown) && pad.yAxis > 0.75) {
					this.handlers[this.conf.dpadDown].isDown = true;
					this._axisDelay = this.axisDelay;
					handledDpad = true;
				} else if (this.handlers.exists(this.conf.dpadUp) && pad.yAxis < -0.75) {
					this.handlers[this.conf.dpadUp].isDown = true;
					this._axisDelay = this.axisDelay;
					handledDpad = true;
				}
			}
		}

		/**
			Handle dpad first
		**/
		if (this.singleHandlePerFrame == true && handledDpad == true) {
			// reset all hold for all buttons except for this.
			for (_ => handler in this.handlers) {
				if (handler.isDown == false) {
					handler.hold = 0;
				} else {
					handler.func();
				}
			}
			return;
		}

		inline function resetAll(except: PadHandler = null) {
			for (h in this.handlers) {
				if (h == except) continue;
				h.hold = 0;
			}
		}

		for (handler in this.handlers) {
			// if we already handle the direction, then we ignore these.
			if (handledDpad == true
				&& (handler.key == this.conf.dpadRight || handler.key == this.conf.dpadLeft
					|| handler.key == this.conf.dpadUp || handler.key == this.conf.dpadDown)) continue;

			if (handler.holdDelay == 0) {
				if (pad.isPressed(handler.key) == true) {
					handler.func();
					if (this.singleHandlePerFrame == true) {
						resetAll();
						break;
					}
				}
			} else {
				if (pad.isDown(handler.key) == true) {
					if (handler.hold < handler.holdDelay) {
						handler.hold += dt;
						if (handler.hold >= handler.holdDelay) {
							handler.func();
							if (handler.repeat == true) handler.hold -= handler.holdDelay;
						}
						resetAll(handler);
						break;
					}
				} else {
					handler.hold = 0;
				}
			}
		}
	}

	public function getHeldDuration(key: Int): Float {
		final handler = this.handlers[key];
		if (handler == null) return 0;
		return handler.hold;
	}

	public function addMapping(key: Int, func: Void->Void, delay: Float = 0, repeat: Bool = false): Bool {
		if (this.handlers.exists(key) == true) return false;

		final handler: PadHandler = {
			key: key,
			func: func,
			holdDelay: delay,
			hold: 0,
			repeat: repeat,
			isDown: false,
		}

		this.handlers.set(key, handler);

		return true;
	}
}
