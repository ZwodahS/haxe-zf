package zf.ui;

import zf.AlignmentUtils;

class TileButton extends h2d.Layers {
    public var text(default, set): Null<String>;
    public var font(default, set): h2d.Font;
    public var disabled(default, set): Bool = false;

    var isOver: Bool = false;

    public var textLabel(default, null): h2d.Text;

    var init: Bool = false;

    var defaultBitmap: h2d.Bitmap;
    var hoverBitmap: h2d.Bitmap;
    var disabledBitmap: h2d.Bitmap;
    var selectedBitmap: h2d.Bitmap;

    public var width(default, null): Float;
    public var height(default, null): Float;

    var useHtmlText: Bool = true;

    public function new(defaultTile: h2d.Tile, hoverTile: h2d.Tile, disabledTile: h2d.Tile,
            selectedTile: h2d.Tile, useHtmlText: Bool = true) {
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
        this.useHtmlText = useHtmlText;

        var interactive = new h2d.Interactive(width, height, this);
        interactive.onOver = function(e: hxd.Event) {
            this.isOver = true;
            updateButton();
            onOver();
        }
        interactive.onOut = function(e: hxd.Event) {
            this.isOver = false;
            updateButton();
            onOut();
        }
        interactive.onClick = function(e: hxd.Event) {
            onClick();
        }
        interactive.onPush = function(e: hxd.Event) {
            onPush();
        }
        interactive.onRelease = function(e: hxd.Event) {
            this.isOver = false;
            updateButton();
            onRelease();
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
        this.textLabel.x = AlignmentUtils.center(0, this.width, textLabel.textWidth);
        this.textLabel.y = AlignmentUtils.center(0, this.height, textLabel.textHeight);
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

    dynamic public function onOut() {}

    dynamic public function onOver() {}

    dynamic public function onClick() {}

    dynamic public function onPush() {}

    dynamic public function onRelease() {}

    public static function fromColor(defaultColor: Int, hoverColor: Int, disabledColor: Int,
            selectedColor: Int, width: Int, height: Int, useHtmlText: Bool = true): TileButton {
        return new TileButton(h2d.Tile.fromColor(defaultColor, width, height),
            h2d.Tile.fromColor(hoverColor, width, height), h2d.Tile.fromColor(disabledColor, width, height),
            h2d.Tile.fromColor(selectedColor, width, height), useHtmlText);
    }
}
