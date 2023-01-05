package zf.tests;

typedef LogEntry = {
	/**
		0 - Info
		50 - Warn
		100 - Error
	**/
	public var level: Int;

	public var message: String;
}
