package zf.ui;

import zf.h2d.Interactive;

using zf.h2d.ObjectExtensions;

@:allow(zf.ui.Button)
class ObjectsButton extends Button {
	/**
		Set the text for the button
	**/
	public var text(default, set): String;

	/**
		flag for if the button is toggled/selected.
	**/
	public var toggled(default, set): Bool = false;

	public function set_toggled(b: Bool): Bool {
		this.toggled = b;
		updateRendering();
		return this.toggled;
	}

	/**
		Get the actual underlying text button
	**/
	var textLabel: h2d.Text;

	var defaultObject: h2d.Object;
	var hoverObject: h2d.Object;
	var disabledObject: h2d.Object;
	var selectedObject: h2d.Object;

	function new() {
		super();
	}

	public function set_text(t: String): String {
		if (this.text == t) return t;
		this.text = t;

		if (this.textLabel != null) updateTextLabel();

		return this.text;
	}

	function updateTextLabel() {
		if (this.textLabel == null) return;
		this.textLabel.text = this.text;
		this.textLabel.setY(this.height, AlignCenter);
	}

	override function updateRendering() {
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
}

typedef ColorButtonConf = {
	public var defaultColor: Null<Color>;
	public var ?hoverColor: Null<Color>;
	public var ?disabledColor: Null<Color>;
	public var ?selectedColor: Null<Color>;
	public var width: Int;
	public var height: Int;
	public var ?font: h2d.Font;
	public var ?textColor: Null<Color>;
	public var ?text: String;
}

typedef TilesButtonConf = {
	public var tiles: Array<h2d.Tile>;
	public var ?font: h2d.Font;
	public var ?textColor: Null<Color>;
	public var ?text: String;
}

typedef ObjectsButtonConf = {
	public var objects: Array<h2d.Object>;
	public var ?font: h2d.Font;
	public var ?textColor: Null<Color>;
	public var ?text: String;
}

typedef TilesColorConf = {
	public var tile: h2d.Tile;
	public var colors: Array<Color>;
	public var ?font: h2d.Font;
	public var ?textColor: Null<Color>;
	public var ?text: String;
}

/**
	Replace the zf.deprecated.ui.GenericButton
	Use this to as a factory to create the specific buttons
**/
class Button extends UIElement {
	/**
		Various builder methods.
	**/
	/**
		Create a button from color
	**/
	public static function fromColor(conf: ColorButtonConf, btn: ObjectsButton = null): ObjectsButton {
		final width = conf.width;
		final height = conf.height;
		final defaultColor = conf.defaultColor;
		final hoverColor = conf.hoverColor == null ? defaultColor : conf.hoverColor;
		final disabledColor = conf.disabledColor == null ? defaultColor : conf.disabledColor;
		final selectedColor = conf.defaultColor == null ? defaultColor : conf.defaultColor;

		if (btn == null) btn = new ObjectsButton();
		btn.addChild(btn.defaultObject = new h2d.Bitmap(h2d.Tile.fromColor(defaultColor, width, height)));
		btn.addChild(btn.hoverObject = new h2d.Bitmap(h2d.Tile.fromColor(hoverColor, width, height)));
		btn.addChild(btn.disabledObject = new h2d.Bitmap(h2d.Tile.fromColor(disabledColor, width, height)));
		btn.addChild(btn.selectedObject = new h2d.Bitmap(h2d.Tile.fromColor(selectedColor, width, height)));

		if (conf.font != null) {
			btn.addChild(btn.textLabel = new h2d.HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}

		btn.addChild(btn.interactive = new Interactive(width, height));
		btn.updateRendering();

		return btn;
	}

	public static function fromTiles(conf: TilesButtonConf, btn: ObjectsButton = null): ObjectsButton {
		final width = conf.tiles[0].width;
		final height = conf.tiles[0].height;
		final defaultTile = conf.tiles[0];
		final hoverTile = conf.tiles.length < 2 || conf.tiles[1] == null ? defaultTile : conf.tiles[1];
		final disabledTile = conf.tiles.length < 3 || conf.tiles[2] == null ? defaultTile : conf.tiles[2];
		final selectedTile = conf.tiles.length < 4 || conf.tiles[3] == null ? defaultTile : conf.tiles[3];

		if (btn == null) btn = new ObjectsButton();
		btn.addChild(btn.defaultObject = new h2d.Bitmap(defaultTile));
		btn.addChild(btn.hoverObject = new h2d.Bitmap(hoverTile));
		btn.addChild(btn.disabledObject = new h2d.Bitmap(disabledTile));
		btn.addChild(btn.selectedObject = new h2d.Bitmap(selectedTile));

		if (conf.font != null) {
			btn.addChild(btn.textLabel = new h2d.HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}
		btn.updateRendering();

		btn.addChild(btn.interactive = new Interactive(width, height));

		return btn;
	}

	public static function fromObjects(conf: ObjectsButtonConf, btn: ObjectsButton = null): ObjectsButton {
		final size = conf.objects[0].getSize();
		final width = size.width;
		final height = size.height;
		if (conf.objects.length < 4) Logger.warn("Cannot support object buttons with less than 4 length");
		final defaultObject = conf.objects[0];
		final hoverObject = conf.objects[1];
		final disabledObject = conf.objects[2];
		final selectedObject = conf.objects[3];

		if (btn == null) btn = new ObjectsButton();
		btn.addChild(btn.defaultObject = defaultObject);
		btn.addChild(btn.hoverObject = hoverObject);
		btn.addChild(btn.disabledObject = disabledObject);
		btn.addChild(btn.selectedObject = selectedObject);

		if (conf.font != null) {
			btn.addChild(btn.textLabel = new h2d.HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}
		btn.updateRendering();

		btn.addChild(btn.interactive = new Interactive(width, height));

		return btn;
	}

	public static function fromTileColors(conf: TilesColorConf, btn: ObjectsButton): ObjectsButton {
		final width = conf.tile.width;
		final height = conf.tile.height;
		final tile = conf.tile;
		final defaultColor = conf.colors[0];
		final hoverColor = conf.colors.length < 2 ? defaultColor : conf.colors[1];
		final disabledColor = conf.colors.length < 3 ? defaultColor : conf.colors[2];
		final selectedColor = conf.colors.length < 4 ? defaultColor : conf.colors[3];

		if (btn == null) btn = new ObjectsButton();
		btn.addChild(btn.defaultObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));
		btn.addChild(btn.hoverObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));
		btn.addChild(btn.disabledObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));
		btn.addChild(btn.selectedObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));

		if (conf.font != null) {
			btn.addChild(btn.textLabel = new h2d.HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}
		btn.updateRendering();

		btn.addChild(btn.interactive = new Interactive(width, height));

		return btn;
	}
}

/**
	Wed 12:45:23 09 Nov 2022
	Replace zf.deprecated.ui.GenericButton
	@todo add "MovementButton"
**/
