package common.ui;

import common.AlignmentUtils;

class TileButton extends h2d.Layers {
    public var text(default, set): Null<String>;
    public var font(default, set): h2d.Font;
    public var disabled(default, set): Bool = false;

    var isOver: Bool = false;

    var textLabel: h2d.HtmlText;
    var init: Bool = false;

    var defaultBitmap: h2d.Bitmap;
    var hoverBitmap: h2d.Bitmap;
    var disabledBitmap: h2d.Bitmap;
    var selectedBitmap: h2d.Bitmap;

    var width: Float;
    var height: Float;

    public function new(defaultTile: h2d.Tile, hoverTile: h2d.Tile, disabledTile: h2d.Tile,
            selectedTile: h2d.Tile) {
        super();
        this.addChild(this.defaultBitmap = new h2d.Bitmap(defaultTile));
        this.addChild(this.hoverBitmap = new h2d.Bitmap(hoverTile));
        this.addChild(this.disabledBitmap = new h2d.Bitmap(disabledTile));
        this.addChild(this.selectedBitmap = new h2d.Bitmap(selectedTile));
        this.width = defaultTile.width;
        this.height = defaultTile.height;
        this.defaultBitmap.visible = true;
        this.hoverBitmap.visible = false;
        this.disabledBitmap.visible = false;
        this.selectedBitmap.visible = false;

        var interactive = new h2d.Interactive(width, height, this);
        interactive.onOver = function(e: hxd.Event) {
            onOver();
        }
        interactive.onOut = function(e: hxd.Event) {
            onOut();
        }
        interactive.onClick = function(e: hxd.Event) {
            onClick();
        }
        interactive.cursor = Default;

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

    public function set_disabled(b: Bool): Bool {
        this.disabled = b;
        updateButton();
        return this.disabled;
    }

    function createTextLabel() {
        if (this.textLabel != null) return;
        if (this.text == null || this.font == null) return; // not ready to create the label
        this.addChild(this.textLabel = new h2d.HtmlText(font));
        this.textLabel.text = this.text;
    }

    function updateTextLabel() {
        if (this.textLabel == null) return;

        this.textLabel.text = this.text;
        this.textLabel.x = AlignmentUtils.center(0, this.width, textLabel.textWidth);
        this.textLabel.y = AlignmentUtils.center(0, this.height, textLabel.textHeight);
    }

    function onOver() {
        this.isOver = true;
        updateButton();
    }

    function updateButton() {
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

    function onOut() {
        this.isOver = false;
        updateButton();
    }

    dynamic public function onClick() {}

    public static function fromColor(defaultColor: Int, hoverColor: Int, disabledColor: Int,
            selectedColor: Int, width: Int, height: Int): TileButton {
        return new TileButton(h2d.Tile.fromColor(defaultColor, width, height),
            h2d.Tile.fromColor(hoverColor, width, height), h2d.Tile.fromColor(disabledColor, width, height),
            h2d.Tile.fromColor(selectedColor, width, height));
    }
}
