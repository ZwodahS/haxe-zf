package zf.ui;

import zf.h2d.Factory;

using zf.h2d.ObjectExtensions;

enum BarType {
	Normal; // Show current and max, with background and foreground of the same color, and background will have a different opacity
	SingleValue; // Show only current value, has no max value.
	StringBar; // Show a String + a color for the string.
	EmptyBar;
}

/**
	@stage:stable
**/
class Bar extends h2d.Object {
	var bg: h2d.Bitmap;
	var bar: h2d.Bitmap;

	public var barColor(default, set): Int;

	var barType: BarType;

	public var value(default, set): Int = 0;
	public var maxValue(default, set): Int = 0;
	public var textValue(default, set): String = null;

	public var width(default, set): Float;
	public var height(default, set): Float;
	public var yOffset(default, set): Float = 0;

	public var text: h2d.Text;

	public function new(barType: BarType, barColor: Int, font: h2d.Font, textColor: Int, width: Float, height: Float,
			tile: h2d.Tile = null) {
		super();

		this.barType = barType;

		if (tile == null) tile = h2d.Tile.fromColor(0xFFFFFF, 1, 1);

		if (barType == Normal) {
			this.addChild(this.bg = new h2d.Bitmap(tile));
			this.bg.color.setColor(barColor);
			this.bg.alpha = 0.3;
			this.bg.width = width;
			this.bg.height = height;
		}

		this.addChild(this.bar = new h2d.Bitmap(tile));
		this.bar.color.setColor(barColor);
		this.bar.width = width;
		this.bar.height = height;
		this.barColor = barColor;

		if (barType != EmptyBar && font != null) {
			this.text = new h2d.Text(font);
			text.textColor = textColor;
			text.x = 0;
			text.y = 0;
			text.textAlign = Center;
			text.maxWidth = width;
			text.text = ' ';
			text.setY(height, AlignCenter);
			this.addChild(text);
		}

		this.width = width;
		this.height = height;
	}

	public function set_barColor(color: Int): Int {
		if (this.barColor == color) return color;
		this.barColor = color;
		if (this.bg != null) this.bg.color.setColor(this.barColor);
		if (this.bar != null) this.bar.color.setColor(this.barColor);
		return this.barColor;
	}

	public function update(valueCurr: Int, valueMax: Null<Int>) {
		if (this.value == valueCurr && this.maxValue == valueMax) return;
		var healthPercentage = valueCurr * 1.0 / valueMax;
		this.bar.width = this.width * healthPercentage;
		this.value = valueCurr;
		this.maxValue = valueMax;
		if (this.text != null) {
			this.text.text = '${valueCurr} / ${valueMax}';
			updateTextPosition();
		}
	}

	public function set_width(w: Float): Float {
		if (this.width == w) return width;
		this.width = w;
		updateBarSize();
		return this.width;
	}

	public function set_height(h: Float): Float {
		if (this.height == h) return height;
		this.height = h;
		updateBarSize();
		return this.height;
	}

	public function set_value(value: Int): Int {
		if (this.value == value) return value;
		this.value = value;
		updateBarSize();
		updateText();
		return this.value;
	}

	public function set_maxValue(v: Int): Int {
		if (this.maxValue == v) return v;
		this.maxValue = v;
		updateBarSize();
		updateText();
		return this.maxValue;
	}

	public function set_textValue(v: String): String {
		if (this.textValue == v) return v;
		this.textValue = v;
		updateText();
		return this.textValue;
	}

	public function set_yOffset(v: Float): Float {
		this.yOffset = v;
		updateTextPosition();
		return this.yOffset;
	}

	function updateText() {
		if (this.text != null) {
			switch (this.barType) {
				case Normal:
					if (this.textValue != null) {
						this.text.text = this.textValue;
					} else {
						this.text.text = '${this.value}/${this.maxValue}';
					}
				case SingleValue:
					if (this.textValue != null) {
						this.text.text = this.textValue;
					} else {
						this.text.text = '${this.value}';
					}
				case StringBar:
					this.text.text = this.textValue == null ? '' : this.textValue;
				default:
			}
		}
	}

	function updateBarSize() {
		if (this.bg != null) {
			this.bg.width = this.width;
			this.bg.height = this.height;
		}
		this.bar.height = this.height;
		if (this.barType == Normal) {
			var healthPercentage = value * 1.0 / maxValue;
			if (healthPercentage < 0) healthPercentage = 0.0;
			this.bar.width = this.width * healthPercentage;
		} else {
			this.bar.width = this.width;
		}
		updateTextPosition();
	}

	function updateTextPosition() {
		if (this.text == null) return;
		this.text.x = 0;
		this.text.y = this.bar.y + this.yOffset + ((height - this.text.textHeight) / 2);
	}
}
