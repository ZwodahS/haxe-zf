package zf.patchnotes;

/**
	@stage:stable

	Define a single change in the game
**/
typedef Change = {
	public var type: ChangeType;
	public var message: String;
}
