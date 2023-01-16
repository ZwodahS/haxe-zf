package zf.ui;

import zf.h2d.Interactive;

/**
	@stage:stable

	A parent class for all UIElement
**/
class UIElement extends h2d.Object {
	public var interactive(default, set): Interactive;

	public var disabled(default, set): Bool = false;

	function set_disabled(b: Bool): Bool {
		this.disabled = b;
		updateRendering();
		return this.disabled;
	}

	public var isOver(default, null): Bool = false;

	inline function set_interactive(i: Interactive): Interactive {
		this.interactive = i;
		// note that the interactive is not added to any parent.
		onInteractiveAttached();
		return this.interactive;
	}

	/**
		This bounds "overrides" the bound instead of using the rendering bound
		@todo override getBounds() and getSize() method later
	**/
	public var bounds: h2d.col.Bounds = null;

	public var width(get, never): Float;

	function get_width() return getSize().width;

	public var height(get, never): Float;

	function get_height() return getSize().height;

	public function new() {
		super();
	}

	function onInteractiveAttached() {
		if (this.interactive == null) return;
		this.interactive.enableRightButton = true;
		this.interactive.propagateEvents = false;

		this.interactive.dyOnRemove = function() {
			_dyOnRemove();
		}
		this.interactive.onOver = function(e: hxd.Event) {
			this.isOver = true;
			updateRendering();
			_onOver(e);
		}
		this.interactive.onOut = function(e: hxd.Event) {
			this.isOver = false;
			updateRendering();
			_onOut(e);
		}
		this.interactive.onClick = function(e: hxd.Event) {
			if (this.disabled) return;
			if (e.button == 0) {
				_onLeftClick(e);
			} else if (e.button == 1) {
				_onRightClick(e);
			}
			_onClick(e);
		}
		this.interactive.onPush = function(e: hxd.Event) {
			updateRendering();
			_onPush(e);
		}
		this.interactive.onRelease = function(e: hxd.Event) {
			updateRendering();
			_onRelease(e);
		}
		this.interactive.onWheel = function(e: hxd.Event) {
			updateRendering();
			_onWheel(e);
		}
		this.interactive.onKeyDown = function(e: hxd.Event) {
			updateRendering();
			_onKeyDown(e);
		}
		this.interactive.onKeyUp = function(e: hxd.Event) {
			updateRendering();
			_onKeyUp(e);
		}
	}

	function updateRendering() {}

	// ---- Event handling for the interactive ---- //

	/**
		Thu 09:55:16 03 Nov 2022
		This uses the same handling as interactive component.
		Instead of creating new interactive, we will add listeners to the interactive in this element.
		This allow us not to have to redefine the interactive especially when there is complex shape involved.
		On top of that, this fits into the system architecture approach.
	**/
	// ---- On out ---- //
	var onOutListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onOut(e: hxd.Event) {
		for (p in this.onOutListeners) p.second(e);
	}

	public function addOnOutListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onOutListeners) {
			if (o.first == id) return false;
		}
		this.onOutListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnOutListener(id: String): Bool {
		for (o in this.onOutListeners) {
			if (o.first == id) {
				this.onOutListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Over ---- //
	var onOverListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onOver(e: hxd.Event) {
		for (p in this.onOverListeners) p.second(e);
	}

	public function addOnOverListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onOverListeners) {
			if (o.first == id) return false;
		}
		this.onOverListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnOverListener(id: String): Bool {
		for (o in this.onOverListeners) {
			if (o.first == id) {
				this.onOverListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Click ---- //
	var onClickListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onClick(e: hxd.Event) {
		for (p in this.onClickListeners) p.second(e);
	}

	public function addOnClickListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onClickListeners) {
			if (o.first == id) return false;
		}
		this.onClickListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnClickListener(id: String): Bool {
		for (o in this.onClickListeners) {
			if (o.first == id) {
				this.onClickListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Left Click ---- //
	var onLeftClickListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onLeftClick(e: hxd.Event) {
		for (p in this.onLeftClickListeners) p.second(e);
	}

	public function addOnLeftClickListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onLeftClickListeners) {
			if (o.first == id) return false;
		}
		this.onLeftClickListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnLeftClickListener(id: String): Bool {
		for (o in this.onLeftClickListeners) {
			if (o.first == id) {
				this.onLeftClickListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Right Click ---- //
	var onRightClickListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onRightClick(e: hxd.Event) {
		for (p in this.onRightClickListeners) p.second(e);
	}

	public function addOnRightClickListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onRightClickListeners) {
			if (o.first == id) return false;
		}
		this.onRightClickListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnRightClickListener(id: String): Bool {
		for (o in this.onRightClickListeners) {
			if (o.first == id) {
				this.onRightClickListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Push ---- //
	var onPushListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onPush(e: hxd.Event) {
		for (p in this.onPushListeners) p.second(e);
	}

	public function addOnPushListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onPushListeners) {
			if (o.first == id) return false;
		}
		this.onPushListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnPushListener(id: String): Bool {
		for (o in this.onPushListeners) {
			if (o.first == id) {
				this.onPushListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Release ---- //
	var onReleaseListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onRelease(e: hxd.Event) {
		for (p in this.onReleaseListeners) p.second(e);
	}

	public function addOnReleaseListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onReleaseListeners) {
			if (o.first == id) return false;
		}
		this.onReleaseListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnReleaseListener(id: String): Bool {
		for (o in this.onReleaseListeners) {
			if (o.first == id) {
				this.onReleaseListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Wheel ---- //
	var onWheelListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onWheel(e: hxd.Event) {
		for (p in this.onWheelListeners) p.second(e);
	}

	public function addOnWheelListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onWheelListeners) {
			if (o.first == id) return false;
		}
		this.onWheelListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnWheelListener(id: String): Bool {
		for (o in this.onWheelListeners) {
			if (o.first == id) {
				this.onWheelListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Removed ---- //
	var onRemoveListeners: Array<Pair<String, Void->Void>> = [];

	public function _dyOnRemove() {
		for (p in this.onRemoveListeners) p.second();
	}

	public function addOnRemoveListener(id: String, func: Void->Void): Bool {
		for (o in this.onRemoveListeners) {
			if (o.first == id) return false;
		}
		this.onRemoveListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnRemoveListener(id: String): Bool {
		for (o in this.onRemoveListeners) {
			if (o.first == id) {
				this.onRemoveListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Key Down ---- //
	var onKeyDownListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onKeyDown(e: hxd.Event) {
		for (p in this.onKeyDownListeners) p.second(e);
	}

	public function addOnKeyDownListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onKeyDownListeners) {
			if (o.first == id) return false;
		}
		this.onKeyDownListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnKeyDownListener(id: String): Bool {
		for (o in this.onKeyDownListeners) {
			if (o.first == id) {
				this.onKeyDownListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Key Up ---- //
	var onKeyUpListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onKeyUp(e: hxd.Event) {
		for (p in this.onKeyUpListeners) p.second(e);
	}

	public function addOnKeyUpListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onKeyUpListeners) {
			if (o.first == id) return false;
		}
		this.onKeyUpListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnKeyUpListener(id: String): Bool {
		for (o in this.onKeyUpListeners) {
			if (o.first == id) {
				this.onKeyUpListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- remove all listeners ---- //
	public function removeAllListeners(id: String) {
		removeOnOutListener(id);
		removeOnOverListener(id);
		removeOnClickListener(id);
		removeOnLeftClickListener(id);
		removeOnRightClickListener(id);
		removeOnPushListener(id);
		removeOnReleaseListener(id);
		removeOnRemoveListener(id);
	}

	public function reset() {
		this.isOver = false;
		updateRendering();
	}
}

/**
	Motivation:

	Often I want to create UI Element onto the screen that are not static, like icons, etc.
	These UI elements usually have features like

	- handling click events
	- tooltips
	- disabling

	Due to the architecture, most of the logic are not in the UIElement, but are in the systems.
	Because of that, I will need to have dynamic functions to handle these interactions,
	and most of the time I need access to the interactive object.

	Wed 19:58:48 02 Nov 2022
	WIP, might want to change of the code here but the idea should be quite fixed.
	Essentially this will be a generalised form of zf.ui.Button
	Ideally that will be refactored to extend this instead.

	Mon 11:44:42 07 Nov 2022
	Another question is whether or not we want Windows to extends this.
	For now we will opt not to do that.
**/
