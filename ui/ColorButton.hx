package common.ui;

import common.AlignmentUtils;

class ColorButton extends h2d.Layers {
    var hover: h2d.Bitmap;

    public var text(default, set): String;

    var textLabel: h2d.Text;

    var width: Float;
    var height: Float;

    var init: Bool = false;

    public function new(width: Int, height: Int, hoverColor: Int, bgColor: Int, text: String,
            font: h2d.Font) {
        super();
        this.add(this.hover = new h2d.Bitmap(h2d.Tile.fromColor(hoverColor, width + 4, height + 4)), 0);
        this.width = width;
        this.height = height;
        this.hover.x = -2;
        this.hover.y = -2;
        this.add(new h2d.Bitmap(h2d.Tile.fromColor(bgColor, width, height)), 1);
        this.textLabel = new h2d.Text(font);
        this.textLabel.text = text;
        this.add(textLabel, 2);

        this.hover.visible = false;
        var interactive = new h2d.Interactive(width, height, this);
        interactive.onOver = function(e: hxd.Event) {
            this.hover.visible = true;
        }
        interactive.onOut = function(e: hxd.Event) {
            this.hover.visible = false;
        }
        interactive.onClick = function(e: hxd.Event) {
            onClick();
        }

        this.init = true;
        updateTextAlignment();
    }

    public function set_text(t: String): String {
        if (this.text == t) return t;
        this.text = t;
        this.textLabel.text = t;
        updateTextAlignment();
        return this.text;
    }

    function updateTextAlignment() {
        if (!this.init) return;
        this.textLabel.x = AlignmentUtils.center(0, this.width, textLabel.textWidth);
        this.textLabel.y = AlignmentUtils.center(0, this.height, textLabel.textHeight);
    }

    dynamic public function onClick() {}
}
