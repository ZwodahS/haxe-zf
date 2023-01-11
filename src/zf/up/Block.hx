package zf.up;

/**
	@stage:stable

	Block is an update that does nothing.

	It will finishes when a flag is set to true.

	This provide a similar mechanism to WaitFor except that the control is handled at the caller side,
	rather than updater.
**/
class Block extends Update {
	public var done: Bool = false;

	public function new() {
		super();
	}

	override public function isDone(): Bool {
		return this.done;
	}
}
