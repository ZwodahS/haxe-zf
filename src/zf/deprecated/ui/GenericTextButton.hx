package zf.deprecated.ui;

/**
	Generic Text Button without any image

	Wed 11:52:37 09 Nov 2022
	This is deprecated as part of the move towards using zf.ui.UIElement
	Kept here as there are some games that are still using it and I am not ready to move them yet.
**/
class GenericTextButton extends Button {
	public var text: h2d.Text;

	public var defaultFontColor(default, set): Color = 0xFFFFFF;
	public var hoverFontColor(default, set): Color = 0xFFFFFF;
	public var disabledFontColor(default, set): Color = 0xFFFFFF;
	public var selectedFontColor(default, set): Color = 0xFFFFFF;

	public function set_defaultFontColor(c: Color): Color {
		this.defaultFontColor = c;
		updateButton();
		return this.defaultFontColor;
	}

	public function set_hoverFontColor(c: Color): Color {
		this.hoverFontColor = c;
		updateButton();
		return this.hoverFontColor;
	}

	public function set_disabledFontColor(c: Color): Color {
		this.disabledFontColor = c;
		updateButton();
		return this.disabledFontColor;
	}

	public function set_selectedFontColor(c: Color): Color {
		this.selectedFontColor = c;
		updateButton();
		return this.selectedFontColor;
	}

	function new(text: h2d.Text) {
		final size = text.getSize();
		super(Std.int(size.width), Std.int(size.height));
		this.text = text;
		this.addChild(this.text);
		updateButton();
	}

	override function updateButton() {
		if (this.disabled == true) {
			this.text.textColor = this.disabledFontColor;
		} else if (this.isOver) {
			this.text.textColor = this.hoverFontColor;
		} else {
			this.text.textColor = this.defaultFontColor;
		}
	}

	public static function fromText(text: h2d.Text): GenericTextButton {
		return new GenericTextButton(text);
	}
}
