package zf.ui;

class TileCheckbox extends h2d.Layers {
	var uncheckedBitmap: h2d.Bitmap;
	var checkedBitmap: h2d.Bitmap;

	public var width(default, null): Float;
	public var height(default, null): Float;
	public var selected(default, set): Bool;

	public function set_selected(b: Bool): Bool {
		this.selected = b;
		if (this.selected) {
			if (uncheckedBitmap != null) uncheckedBitmap.visible = false;
			if (checkedBitmap != null) checkedBitmap.visible = true;
		} else {
			if (uncheckedBitmap != null) uncheckedBitmap.visible = true;
			if (checkedBitmap != null) checkedBitmap.visible = false;
		}
		if (this.init) this.onValueChanged(this.selected);
		return this.selected;
	}

	var init = false;

	public function new(uncheckTile: h2d.Tile, checkedTile: h2d.Tile, default_value: Bool = true) {
		super();
		this.uncheckedBitmap = new h2d.Bitmap(uncheckTile);
		this.checkedBitmap = new h2d.Bitmap(checkedTile);
		this.addChild(this.uncheckedBitmap);
		this.addChild(this.checkedBitmap);

		this.width = uncheckTile.width;
		this.height = uncheckTile.height;

		var interactive = new h2d.Interactive(width, height, this);
		interactive.onClick = function(e: hxd.Event) {
			this.selected = !this.selected;
		}
		this.selected = default_value;
		this.init = true;
	}

	dynamic public function onValueChanged(selected: Bool) {}
}
