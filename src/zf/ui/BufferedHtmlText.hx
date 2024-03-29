package zf.ui;

import zf.h2d.HtmlText;

/**
	@stage:stable

	A Html text that can be used to buffer a list of strings
**/
class BufferedHtmlText extends HtmlText {
	var bufferedTexts: List<String>;
	var onFinish: Void->Void;
	var current: String;

	public var progress(default, set): Float;

	public function new(font: h2d.Font) {
		super(font);
		this.bufferedTexts = new List<String>();
		this.onFinish = null;
		this.current = null;
		this.progress = 0.0;
	}

	/**
		set the display text to this value
	**/
	public function displayText(text: String) {
		this.text = text;
		this.current = text;
		this.progress = 1.0;
	}

	/**
		buffer a list of texts, and slowly display them.
	**/
	public function bufferTexts(texts: Iterable<String>, onFinish: Void->Void) {
		this.bufferedTexts.clear();
		for (t in texts) this.bufferedTexts.add(t);
		this.onFinish = onFinish;
		this.progress = 0;
	}

	public function update(dt: Float) {
		if (this.progress >= 1.0) return;
		if (this.current == null) nextDialog();
		this.progress += dt;
	}

	public function set_progress(f: Float): Float {
		this.progress = f;
		if (this.progress >= 1.0) this.progress = 1.0;
		if (this.current == null) return this.progress;

		this.text = getTextProgress(this.current, this.progress * this.current.length);
		return this.progress;
	}

	inline public function hasNext(): Bool {
		return bufferedTexts.length > 0 || onFinish != null;
	}

	inline public function nextDialog() {
		if (this.bufferedTexts.length == 0) {
			this.current = null;
			if (this.onFinish != null) {
				this.onFinish();
				this.onFinish = null;
			}
			return;
		}

		this.current = bufferedTexts.pop();
		this.text = '';
		this.progress = 0;
	}
}
