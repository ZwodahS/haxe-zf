package zf.tests;

typedef TestResult = {
	public var success: Bool;
	public var ?failure: String;
	public var ?exception: haxe.Exception;
	public var ?stackItems: Array<haxe.CallStack.StackItem>;
	public var ?step: Int;
	public var ?stepId: String;
}
