package zf.resources;

/**
	Define a language
**/
typedef LanguageResource = {
	/**
		For now we will define font by specifying a name
	**/
	public var font: {
		public var ?name: String;
	}

	/**
		The name to display
	**/
	public var displayName: String;

	/**
		Key to store the language.
		en will always be the default.
	**/
	public var key: String;

	// array of paths relative from the language folder
	public var strings: Array<String>;
}
