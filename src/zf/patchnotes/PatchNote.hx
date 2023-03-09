package zf.patchnotes;

/**
	@stage:stable

	Define a single patch note
**/
typedef PatchNote = {
	public var date: String;

	public var version: String;
	public var versionObject: Version;

	/**
		Messages are store as an array of string and is joined with new line to be displayed.
	**/
	public var ?messages: Array<String>;

	/**
		List of changes
	**/
	public var ?changes: Array<Change>;
}
