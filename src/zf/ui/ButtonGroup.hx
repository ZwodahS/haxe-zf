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
	public function new(buttons: Array<Button>) {
		this.buttons = buttons;

		for (btn in this.buttons) {
			btn.addOnClickListener("ButtonGroup", (e) -> {
				toggleButton(btn);
			});
		}

		if (this.buttons.length != 0) toggleButton(this.buttons[0]);
	}

	function toggleButton(btn: Button) {
		for (i => b in this.buttons) {
			b.toggled = btn == b;
		}
		onToggled(btn);
	}

	dynamic public function onToggled(btn: Button) {}
}
