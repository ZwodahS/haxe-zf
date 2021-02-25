package zf.ui;

import zf.h2d.Factory;

enum BarType {
	Normal; // Show current and max, with background and foreground of the same color, and background will have a different opacity
	SingleValue; // Show only current value, has no max value.
	StringBar; // Show a String + a color for the string.
	EmptyBar;
}

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

	var text: h2d.Text;

	public function new(barType: BarType, barColor: Int, font: h2d.Font, textColor: Int, width: Float,
			height: Float) {
		super();

		this.barType = barType;

		if (barType == Normal) {
			this.addChild(this.bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 1, 1)));
			this.bg.color.setColor(barColor);
			this.bg.alpha = 0.3;
			this.bg.width = width;
			this.bg.height = height;
		}

		this.addChild(this.bar = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 1, 1)));
		this.bar.color.setColor(barColor);
		this.bar.width = width;
		this.bar.height = height;
		this.barColor = barColor;

		if (barType != EmptyBar) {
			this.addChild(this.text = Factory.text(new h2d.Text(font))
				.textColor(textColor)
				.position(0, 0)
				.setText('')
				.centerHorizontal(this.bar.x + width / 2)
				.centerVertical(this.bar.y + height / 2)
				.text);
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
			this.text.x = this.bar.x + ((width - this.text.textWidth) / 2);
			this.text.y = this.bar.y + ((height - this.text.textHeight) / 2);
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
		updateText();
		return this.value;
	}

	public function set_maxValue(v: Int): Int {
		if (this.maxValue == v) return v;
		this.maxValue = v;
		updateText();
		return this.maxValue;
	}

	public function set_textValue(v: String): String {
		if (this.textValue == v) return v;
		this.textValue = v;
		updateText();
		return this.textValue;
	}

	function updateText() {
		if (this.text == null) return;
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
		this.text.x = (this.bar.x + width / 2) - this.text.textWidth / 2;
		updateBarSize();
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
		this.text.x = this.bar.x + ((width - this.text.textWidth) / 2);
		this.text.y = this.bar.y + ((height - this.text.textHeight) / 2);
	}
}
