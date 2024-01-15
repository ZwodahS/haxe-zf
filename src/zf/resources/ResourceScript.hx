package zf.resources;

import zf.resources.FontResource;
import zf.resources.SoundResource;

typedef ScaleGridConf = {
	public var id: String;
	public var assetId: String;
	public var borderL: Int;
	public var borderT: Int;
	public var ?borderR: Int;
	public var ?borderB: Int;
	public var ?color: Int;
}

typedef PathConf = {
	public var path: String;
}

/**
	Extended resource script.

	We will pass a resource manager context to set up more things.

	Tue 15:43:13 26 Dec 2023
	Motivation

	Json does not allow for comments, or scripts.
	The json will be kept for now, but will eventually be deprecated and older projects need to be updated.

	Also, since multiple scripts can be loaded with resource manager, we don't have to put
	all of these in a single file.
**/
typedef ResourceScript = {
	/**
		Spritesheets

		Path to the aseprite json file
	**/
	public var ?spritesheets: Array<PathConf>;

	/**
		Fonts

		This mirrors the font files
	**/
	public var ?fonts: Array<FontGroup>;

	/**
		Languages
	**/
	public var ?languages: Array<LanguageResource>;

	/**
		Sounds
	**/
	public var ?sounds: Array<SoundResourceConf>;

	/**
		Colors
	**/
	public var ?colors: Map<String, Dynamic>;

	/**
		Define scale grids
	**/
	public var ?scalegrids: Array<ScaleGridConf>;

	/**
		Init function to run
	**/
	public var ?init: (ResourceManagerContext) -> Void;
}
