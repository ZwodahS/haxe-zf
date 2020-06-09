package common;

class Factory {
    public static function createH2dText(font: h2d.Font, text: String, position: Point2f = null,
            color: h3d.Vector = null, maxWidth: Int = null) {
        var t = new h2d.Text(font);
        t.text = text;

        if (position != null) {
            t.x = position.x;
            t.y = position.y;
        }
        if (color != null) t.color = color;
        if (maxWidth != null) t.maxWidth = maxWidth;

        // complicated logic

        return t;
    }
}
