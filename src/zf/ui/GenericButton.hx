package zf.ui;

using zf.h2d.ObjectExtensions;

/**
	Generic Button using a h2d.Object as background with a text
**/
class GenericButton extends Button {
	/**
		Set the text for the button
	**/
	public var text(default, set): String;

	/**
		Set the font for the text above the button
	**/
	public var font(default, set): h2d.Font;

	/**
		Get the actual underlying text button
	**/
	public var textLabel(default, null): h2d.Text;

	var init: Bool = false;

	var defaultObject: h2d.Object;
	var hoverObject: h2d.Object;
	var disabledObject: h2d.Object;
	var selectedObject: h2d.Object;

	var useHtmlText: Bool = true;

	public function new(defaultObject: h2d.Object, hoverObject: h2d.Object, disabledObject: h2d.Object,
			selectedObject: h2d.Object, useHtmlText: Bool = true) {
		final size = defaultObject.getSize();
		super(Std.int(size.width), Std.int(size.height));

		this.addChild(this.defaultObject = defaultObject);
		this.addChild(this.hoverObject = hoverObject);
		this.addChild(this.disabledObject = disabledObject);
		this.addChild(this.selectedObject = selectedObject);

		this.defaultObject.visible = true;
		this.hoverObject.visible = false;
		this.disabledObject.visible = false;
		this.selectedObject.visible = false;
		this.useHtmlText = useHtmlText;

		this.init = true;
		updateTextLabel();
	}

	public function set_text(t: String): String {
		if (this.text == t) return t;
		this.text = t;

		if (this.text == null) {
			if (this.textLabel != null) {
				this.textLabel.remove();
				this.textLabel = null;
			}
		} else {
			createTextLabel();
		}

		if (this.textLabel != null) {
			updateTextLabel();
		}
		return this.text;
	}

	public function set_font(f: h2d.Font): h2d.Font {
		if (this.font == f) return this.font;
		this.font = f;
		updateTextLabel();
		return this.font;
	}

	function createTextLabel() {
		if (this.textLabel != null) return;
		if (this.text == null || this.font == null) return; // not ready to create the label
		if (this.useHtmlText) {
			this.addChild(this.textLabel = new h2d.HtmlText(font));
		} else {
			this.addChild(this.textLabel = new h2d.Text(font));
		}
		this.textLabel.text = this.text;
	}

	function updateTextLabel() {
		if (this.textLabel == null) return;

		this.textLabel.text = this.text;
		this.textLabel.setX(this.width, AlignCenter);
		this.textLabel.setY(this.height, AlignCenter);
	}

	override function updateButton() {
		this.defaultObject.visible = false;
		this.hoverObject.visible = false;
		this.disabledObject.visible = false;
		this.selectedObject.visible = false;
		if (this.disabled == true) {
			this.disabledObject.visible = true;
		} else if (this.toggled == true) {
			this.selectedObject.visible = true;
		} else if (this.isOver == true) {
			this.hoverObject.visible = true;
		} else {
			this.defaultObject.visible = true;
		}
		onStateChanged();
	}

	/**
		Sometimes you might want to change the button even further when the state changed.
	**/
	dynamic public function onStateChanged() {}

	/**
		Various builder methods.
	**/
	/**
		Create a button from color
	**/
	public static function fromColor(defaultColor: Int, hoverColor: Int, disabledColor: Int, selectedColor: Int,
			width: Int, height: Int, useHtmlText: Bool = true): GenericButton {
		// @formatter:off
		return new GenericButton(
			new h2d.Bitmap(h2d.Tile.fromColor(defaultColor, width, height)),
			new h2d.Bitmap(h2d.Tile.fromColor(hoverColor, width, height)),
			new h2d.Bitmap(h2d.Tile.fromColor(disabledColor, width, height)),
			new h2d.Bitmap(h2d.Tile.fromColor(selectedColor, width, height)),
			useHtmlText
		);
	}

	public static function fromTiles(tiles: Array<h2d.Tile>): GenericButton {
		final defaultTile = tiles[0];
		final hoverTile = tiles.length > 1 ? tiles[1] : tiles[0];
		final disabledTile = tiles.length > 2 ? tiles[2] : tiles[0];
		final selectedTile = tiles.length > 3 ? tiles[3] : tiles[0];
		return new GenericButton(
			new h2d.Bitmap(defaultTile),
			new h2d.Bitmap(hoverTile),
			new h2d.Bitmap(disabledTile),
			new h2d.Bitmap(selectedTile)
		);
	}

	public static function fromTileColors(tile: h2d.Tile, colors: Array<Int>): GenericButton {
		final defaultColor = colors[0];
		final hoverColor = colors.length > 1 ? colors[1] : colors[0];
		final disabledColor = colors.length > 2 ? colors[2] : colors[0];
		final selectedColor = colors.length > 3 ? colors[3] : colors[0];
		inline function makeBitmap(color: Int): h2d.Bitmap {
			final bm = new h2d.Bitmap(tile);
			bm.color.setColor(color);
			return bm;
		}
		return new GenericButton(
			makeBitmap(defaultColor),
			makeBitmap(hoverColor),
			makeBitmap(disabledColor),
			makeBitmap(selectedColor)
		);
	}
}
