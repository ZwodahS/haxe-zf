package zf.ui;

import zf.ui.Button;

/**
	@stage:stable

	Allow us to group buttons together and handle the toggled state here.
**/
class ButtonGroup {
	var buttons: Array<Button>;

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
		if (defaultToggle == null) toggleButton(defaultToggle);
	}

	function toggleButton(btn: Button) {
		for (i => b in this.buttons) {
			b.toggled = btn == b;
		}
		this.onToggle(btn);
	}

	dynamic public function onToggle(btn: Button) {}
}
