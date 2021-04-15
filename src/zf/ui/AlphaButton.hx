package zf.ui;

/**
	Change alpha based on button state.
	This is mainly used for prototyping.
**/
class AlphaButton extends Button {
	public var disabledAlpha: Float = .5;
	public var untoggledAlpha: Float = .5;
	public var hoverAlpha: Float = 1;

	public function new(width: Int, height: Int, disabledAlpha = .5, untoggledAlpha = .5, hoverAlpha = 1) {
		super(width, height);
		this.disabledAlpha = disabledAlpha;
		this.untoggledAlpha = untoggledAlpha;
		this.hoverAlpha = hoverAlpha;
	}

	override function updateButton() {
		if (this.isOver) {
			this.alpha = hoverAlpha;
		} else if (this.disabled) {
			this.alpha = disabledAlpha;
		} else if (!this.toggled) {
			this.alpha = untoggledAlpha;
		} else {
			this.alpha = 1;
		}
	}
}
