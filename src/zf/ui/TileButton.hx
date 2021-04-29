package zf.ui;

using zf.h2d.ObjectExtensions;

class TileButton extends Button {
	public var text(default, set): Null<String>;
	public var font(default, set): h2d.Font;
	public var textLabel(default, null): h2d.Text;

	var init: Bool = false;

	var defaultBitmap: h2d.Bitmap;
	var hoverBitmap: h2d.Bitmap;
	var disabledBitmap: h2d.Bitmap;
	var selectedBitmap: h2d.Bitmap;

	var useHtmlText: Bool = true;

	public function new(defaultTile: h2d.Tile, hoverTile: h2d.Tile, disabledTile: h2d.Tile,
			selectedTile: h2d.Tile, useHtmlText: Bool = true) {
		super(Std.int(defaultTile.width), Std.int(defaultTile.height));
		this.addChild(this.defaultBitmap = new h2d.Bitmap(defaultTile));
		this.addChild(this.hoverBitmap = new h2d.Bitmap(hoverTile));
		this.addChild(this.disabledBitmap = new h2d.Bitmap(disabledTile));
		this.addChild(this.selectedBitmap = new h2d.Bitmap(selectedTile));
		this.defaultBitmap.visible = true;
		this.hoverBitmap.visible = false;
		this.disabledBitmap.visible = false;
		this.selectedBitmap.visible = false;
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
		this.defaultBitmap.visible = false;
		this.hoverBitmap.visible = false;
		this.disabledBitmap.visible = false;
		this.selectedBitmap.visible = false;
		if (this.disabled) {
			this.disabledBitmap.visible = true;
		} else if (this.isOver) {
			this.hoverBitmap.visible = true;
		} else {
			this.defaultBitmap.visible = true;
		}
	}

	public static function fromColor(defaultColor: Int, hoverColor: Int, disabledColor: Int,
			selectedColor: Int, width: Int, height: Int, useHtmlText: Bool = true): TileButton {
		return new TileButton(h2d.Tile.fromColor(defaultColor, width, height),
			h2d.Tile.fromColor(hoverColor, width, height), h2d.Tile.fromColor(disabledColor, width, height),
			h2d.Tile.fromColor(selectedColor, width, height), useHtmlText);
	}

	public static function fromTiles(tiles: Array<h2d.Tile>): TileButton {
		var defaultTile = tiles[0];
		var hoverTile = tiles.length > 1 ? tiles[1] : tiles[0];
		var disabledTile = tiles.length > 2 ? tiles[2] : tiles[0];
		var selectedTile = tiles.length > 3 ? tiles[3] : tiles[0];
		return new TileButton(defaultTile, hoverTile, disabledTile, selectedTile);
	}
}
