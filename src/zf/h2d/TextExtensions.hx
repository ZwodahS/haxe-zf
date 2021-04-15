package zf.h2d;

class TextExtensions {
	public static function setText(t: h2d.Text, text: String): h2d.Text {
		t.text = text;
		return t;
	}
}
