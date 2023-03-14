package zf.resources;

typedef MSDFConf = {
	public var file: String;
	public var size: Array<Int>;
}

typedef FontConf = {
	public var type: String;
	public var conf: Dynamic;
}

typedef LanguageFontConf = {
	/**
		The language id.
	**/
	public var language: String;

	public var fonts: Dynamic;
}

/**
	Define a language font information
**/
typedef SingleLanguageFontType = {
	public var sourceFont: hxd.res.BitmapFont;
	public var fonts: Array<h2d.Font>;
}

typedef LanguageFont = {
	/**
		the language name
	**/
	public var language: String;

	/**
		the mapped fonts
	**/
	public var fonts: Map<String, SingleLanguageFontType>;
}
