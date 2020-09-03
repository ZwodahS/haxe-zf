package common;

class HtmlUtils {
    public static function font(text: String, color: Int): String {
        return
            '<font color="#${StringTools.hex(color & 0xFFFFFF, 6)}">${StringTools.htmlEscape(text)}</font>';
    }
}
