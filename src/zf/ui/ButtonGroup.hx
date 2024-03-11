package zf.ui;

import zf.ui.Button;

/**
	@stage:stable

	Allow us to group buttons together and handle the toggled state here.
**/
class ButtonGroup {
	var buttons: Array<Button>;

	public var selected(get, never): Button;

	public function get_selected(): Button {
		for (b in this.buttons) {
			if (b.toggled) return b;
		}
		return null;
	}

	/**
		The first button will be toggled by default
	**/
	public function new(buttons: Array<Button>, defaultToggle: Button = null) {
		this.buttons = buttons;

		for (btn in this.buttons) {
			btn.addOnClickListener("ButtonGroup", (e) -> {
				toggleButton(btn);
			});
		}

		if (defaultToggle == null) defaultToggle = this.buttons.length != 0 ? this.buttons[0] : null;
		if (defaultToggle != null) _toggle(defaultToggle);
	}

	public function toggleButton(btn: Button) {
		final canToggle = this.canToggle(this.selected, btn);
		if (canToggle == false) return;

		_toggle(btn);
	}

	function _toggle(btn: Button) {
		for (i => b in this.buttons) {
			b.toggled = btn == b;
		}
		this.onToggle(btn);
	}

	dynamic public function onToggle(btn: Button) {}

	dynamic public function canToggle(current: Button, btn: Button): Bool {
		return true;
	}
}
