package zf.ui;

import zf.h2d.Interactive;

/**
	Generic Button object.
	This is the parent for all button and Child object should implement the rendering.
**/
class Button extends h2d.Layers {
	/**
		flag for if the button is disabled.
	**/
	public var disabled(default, set): Bool = false;

	/**
		flag for if the button is toggled/selected.
	**/
	public var toggled(default, set): Bool = true;

	var isOver: Bool = false;
	var interactive: Interactive;

	/**
		width of the interactive part of the button.
	**/
	public var width(default, null): Int;

	/**
		height of the interactive part of the button.
	**/
	public var height(default, null): Int;

	public function set_disabled(b: Bool): Bool {
		this.disabled = b;
		updateButton();
		return this.disabled;
	}

	public function set_toggled(b: Bool): Bool {
		this.toggled = b;
		updateButton();
		return this.toggled;
	}

	public function new(width: Int, height: Int) {
		super();
		this.width = width;
		this.height = height;
		this.interactive = new Interactive(width, height, this);
		this.interactive.enableRightButton = true;

		interactive.dyOnRemove = function() {
			dyOnRemove();
		}
		interactive.onOver = function(e: hxd.Event) {
			this.isOver = true;
			updateButton();
			onOver();
		}
		interactive.onOut = function(e: hxd.Event) {
			this.isOver = false;
			updateButton();
			onOut();
		}
		interactive.onClick = function(e: hxd.Event) {
			if (this.disabled) return;
			if (e.button == 0) {
				onLeftClick();
			} else if (e.button == 1) {
				onRightClick();
			}
			onClick(e.button);
		}
		interactive.onPush = function(e: hxd.Event) {
			onPush();
		}
		interactive.onRelease = function(e: hxd.Event) {
			this.isOver = false;
			updateButton();
			onRelease();
		}
		interactive.cursor = Default;
	}

	dynamic public function onOut() {}

	dynamic public function onOver() {}

	dynamic public function onClick(button: Int) {}

	dynamic public function onLeftClick() {}

	dynamic public function onRightClick() {}

	dynamic public function onPush() {}

	dynamic public function onRelease() {}

	dynamic public function dyOnRemove() {}

	/**
		Update the button. This is called when state is changed.
	**/
	function updateButton() {}
}
