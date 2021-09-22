package zf.ui;

/**
	Generic Checkbox using h2d.Object as image
**/

class GenericCheckbox extends h2d.Layers {
	var uncheckedObject: h2d.Object;
	var checkedObject: h2d.Object;

	public var width(default, null): Float;
	public var height(default, null): Float;
	public var selected(default, set): Bool;

	public function set_selected(b: Bool): Bool {
		this.selected = b;
		if (this.selected) {
			if (uncheckedObject != null) uncheckedObject.visible = false;
			if (checkedObject != null) checkedObject.visible = true;
		} else {
			if (uncheckedObject != null) uncheckedObject.visible = true;
			if (checkedObject != null) checkedObject.visible = false;
		}
		if (this.init) this.onValueChanged(this.selected);
		return this.selected;
	}

	var init = false;

	public function new(uncheckedObject: h2d.Object, checkedObject: h2d.Object, defaultValue: Bool = true) {
		super();
		this.addChild(this.uncheckedObject = uncheckedObject);
		this.addChild(this.checkedObject = checkedObject);

		final size = this.uncheckedObject.getSize();
		this.width = size.width;
		this.height = size.height;

		var interactive = new h2d.Interactive(this.width, this.height, this);
		interactive.onClick = function(e: hxd.Event) {
			this.selected = !this.selected;
		}
		this.selected = defaultValue;
		this.init = true;
	}

	dynamic public function onValueChanged(selected: Bool) {}

	/**
		Various builder methods
	**/

	public static function fromTiles(tiles: Array<h2d.Tile>, defaultValue: Bool = true): GenericCheckbox {
		return new GenericCheckbox(new h2d.Bitmap(tiles[0]), new h2d.Bitmap(tiles[1]), defaultValue);
	}
}
