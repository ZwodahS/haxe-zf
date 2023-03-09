package zf.patchnotes;

/**
	@stage:stable

	Define the type of change
**/
enum abstract ChangeType(String) from String to String {
	public var Feature = "feature";
	public var UI = "ui";
	public var BugFix = "fix";
	public var Qol = "qol";
	public var Balance = "balance";
}
