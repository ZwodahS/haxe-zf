package zf.resources;

typedef LoadedFontGroup = {
	public var sourceFont: hxd.res.BitmapFont;
	public var fonts: Array<h2d.Font>;
}

/**
	Define a font
**/
typedef FontConf = {
	public var type: String;

	/**
		conf currently only support MSDFConf
	**/
	public var conf: Dynamic;
}

typedef MSDFConf = {
	public var file: String;
	public var size: Array<Int>;
}

/**
	Define a font group.

	fonts: Map<String, FontConf>
**/
typedef FontGroup = {
	public var id: String;
	public var fonts: Dynamic;
}

/**
	Define how a font file looks like

	{
		fonts: [
			FontGroup
		]
	}
**/
typedef FontFile = {
	public var fonts: Array<FontGroup>;
}
