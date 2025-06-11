package zf.ui;

import zf.h2d.HtmlText;
import zf.h2d.Interactive;
import zf.h2d.ScaleGrid;
import zf.ui.ScaleGridFactory;

using zf.h2d.ObjectExtensions;

@:allow(zf.ui.Button)
class ObjectsButton extends Button {
	/**
		Set the text for the button
	**/
	public var text(default, set): String;

	/**
		Get the actual underlying text button
	**/
	var textLabel: HtmlText;

	var defaultObject: h2d.Object;
	var hoverObject: h2d.Object;
	var disabledObject: h2d.Object;
	var selectedObject: h2d.Object;

	public var floatOffset: Point2f = [0, 0];

	public var display: h2d.Object;

	public var textOffset(default, set): Point2f;

	public function set_textOffset(v: Point2f): Point2f {
		this.textOffset = v;
		alignText();
		return this.textOffset;
	}

	function new() {
		super();
		this.textOffset = [0, 0];
		this.addChild(this.display = new h2d.Object());
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
		alignText();
	}

	function alignText() {
		if (this.textLabel == null) return;
		this.textLabel.setX(this.textOffset.x).setY(this.height, AlignCenter, this.textOffset.y);
	}

	override function updateRendering() {
		this.defaultObject.visible = false;
		this.hoverObject.visible = false;
		this.disabledObject.visible = false;
		this.selectedObject.visible = false;

		if (this.disabled == true) {
			this.disabledObject.visible = true;
			this.display.setX(0).setY(0);
		} else if (this.toggled == true) {
			this.selectedObject.visible = true;
			this.display.setX(0).setY(0);
		} else if (this.isOver == true) {
			this.hoverObject.visible = true;
			this.display.setX(this.floatOffset.x).setY(this.floatOffset.y);
		} else {
			this.defaultObject.visible = true;
			this.display.setX(0).setY(0);
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
	// starts with the first font in the list, and resize if it is too big
	public var ?autoFonts: {
		public var fonts: Array<h2d.Font>;
		public var maxWidth: Int;
	};
	public var ?floatOffset: {
		public var ?x: Float;
		public var ?y: Float;
	};
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
	Handle scalegrid button which scale up size based on the text side
**/
@:allow(zf.ui.Button)
class ScaleGridButton extends Button {
	var paddingUp: Int = 0;
	var paddingLeft: Int = 0;
	var paddingDown: Int = 0;
	var paddingRight: Int = 0;

	public var display: h2d.Object;

	var defaultObject: ScaleGrid;
	var hoverObject: ScaleGrid;
	var disabledObject: ScaleGrid;
	var selectedObject: ScaleGrid;

	var textLabel: HtmlText;

	public var text(get, set): String;

	inline function get_text(): String {
		return this.textLabel.text;
	}

	public function set_text(v: String): String {
		this.textLabel.text = v;
		resizeButton();
		return this.textLabel.text;
	}

	function new() {
		super();
		this.addChild(this.display = new h2d.Object());
	}

	function resizeButton() {
		final size = this.textLabel.getSize();
		final width: Int = this.paddingLeft + this.paddingRight + Std.int(size.width);
		final height: Int = this.paddingUp + this.paddingDown + Std.int(size.height);
		this.defaultObject.width = width;
		this.defaultObject.height = height;
		this.hoverObject.width = width;
		this.hoverObject.height = height;
		this.disabledObject.width = width;
		this.disabledObject.height = height;
		this.selectedObject.width = width;
		this.selectedObject.height = height;
		this.textLabel.setX(paddingLeft).setY(paddingUp);
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
		// TODO: I think we need a 5th state for on pressed ?
		onStateChanged();
	}

	/**
		Sometimes you might want to change the button even further when the state changed.
	**/
	dynamic public function onStateChanged() {}
}

typedef ScaleGridConf = {
	public var defaultObject: ScaleGridFactory;
	public var ?hoverObject: ScaleGridFactory;
	public var ?disabledObject: ScaleGridFactory;
	public var ?selectedObject: ScaleGridFactory;

	/**
		Pad the [up, (left), (down), (right)] side of the button
		(right) will default to (left) if not present)
		(down) will default to (up) if not present
		(left) will default to (up) if not present
		If field is empty, default to 0 spacing
	**/
	public var ?padding: Array<Int>;

	public var ?textColor: Null<Color>;
	public var ?text: String;
	public var ?font: h2d.Font;
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
		final selectedColor = conf.selectedColor == null ? defaultColor : conf.selectedColor;

		if (btn == null) btn = new ObjectsButton();
		btn.display.addChild(btn.defaultObject = new h2d.Bitmap(h2d.Tile.fromColor(defaultColor, width, height)));
		btn.display.addChild(btn.hoverObject = new h2d.Bitmap(h2d.Tile.fromColor(hoverColor, width, height)));
		btn.display.addChild(btn.disabledObject = new h2d.Bitmap(h2d.Tile.fromColor(disabledColor, width, height)));
		btn.display.addChild(btn.selectedObject = new h2d.Bitmap(h2d.Tile.fromColor(selectedColor, width, height)));

		if (conf.font != null) {
			btn.display.addChild(btn.textLabel = new HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}
		btn.alignText();

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
		btn.display.addChild(btn.defaultObject = new h2d.Bitmap(defaultTile));
		btn.display.addChild(btn.hoverObject = new h2d.Bitmap(hoverTile));
		btn.display.addChild(btn.disabledObject = new h2d.Bitmap(disabledTile));
		btn.display.addChild(btn.selectedObject = new h2d.Bitmap(selectedTile));

		if (conf.font != null) {
			btn.display.addChild(btn.textLabel = new HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}
		btn.updateRendering();
		btn.alignText();

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
		btn.display.addChild(btn.defaultObject = defaultObject);
		btn.display.addChild(btn.hoverObject = hoverObject);
		btn.display.addChild(btn.disabledObject = disabledObject);
		btn.display.addChild(btn.selectedObject = selectedObject);

		if (conf.font != null) {
			btn.display.addChild(btn.textLabel = new HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		} else if (conf.autoFonts != null) {
			final fonts = conf.autoFonts.fonts;
			btn.display.addChild(btn.textLabel = new HtmlText(fonts[0]));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			var i = 1;
			while (i < fonts.length && btn.textLabel.textWidth > conf.autoFonts.maxWidth) {
				btn.textLabel.font = fonts[i];
				i += 1;
			}
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}

		if (conf.floatOffset != null) {
			if (conf.floatOffset.x != null) btn.floatOffset.x = conf.floatOffset.x;
			if (conf.floatOffset.y != null) btn.floatOffset.y = conf.floatOffset.y;
		}
		btn.updateRendering();
		btn.alignText();

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
		btn.display.addChild(btn.defaultObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));
		btn.display.addChild(btn.hoverObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));
		btn.display.addChild(btn.disabledObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));
		btn.display.addChild(btn.selectedObject = (new h2d.Bitmap(tile)).cSetColor(defaultColor));

		if (conf.font != null) {
			btn.display.addChild(btn.textLabel = new HtmlText(conf.font));
			if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;
			if (conf.text != null) btn.text = conf.text;
			btn.textLabel.maxWidth = width;
			btn.textLabel.textAlign = Center;
		}
		btn.updateRendering();
		btn.alignText();

		btn.addChild(btn.interactive = new Interactive(width, height));

		return btn;
	}

	public static function fromScaleGrid(conf: ScaleGridConf): Button {
		final btn = new ScaleGridButton();

		if (conf.padding != null) {
			btn.paddingUp = conf.padding.length == 0 ? 0 : conf.padding[0];
			btn.paddingLeft = conf.padding.length > 1 ? conf.padding[1] : btn.paddingUp;
			btn.paddingDown = conf.padding.length > 2 ? conf.padding[2] : btn.paddingUp;
			btn.paddingRight = conf.padding.length > 3 ? conf.padding[3] : btn.paddingLeft;
		}

		final size: Point2i = [27, 12];
		btn.display.addChild(btn.defaultObject = conf.defaultObject.make(size.x, size.y));
		btn.display.addChild(btn.hoverObject = (conf.hoverObject ?? conf.defaultObject).make(size.x, size.y));
		btn.display.addChild(btn.disabledObject = (conf.disabledObject ?? conf.defaultObject).make(size.x, size.y));
		btn.display.addChild(btn.selectedObject = (conf.selectedObject ?? conf.defaultObject).make(size.x, size.y));
		size.dispose();

		btn.display.addChild(btn.textLabel = new HtmlText(conf.font));
		if (conf.textColor != null) btn.textLabel.textColor = conf.textColor;

		btn.updateRendering();

		if (conf.text != null) btn.text = conf.text;

		btn.addChild(btn.interactive = new Interactive(btn.width, btn.height));

		return btn;
	}
}

/**
	Wed 12:45:23 09 Nov 2022
	Replace zf.deprecated.ui.GenericButton
	@todo add "MovementButton"
**/
