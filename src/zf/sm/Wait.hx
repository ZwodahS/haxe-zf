package zf.sm;

/**
	A Generic Wait State

	This will wait for a function to return true before returning the next state

	If WaitFor is not provided, it will block forever and the state should be manually set
**/
class Wait extends State {
	public var nextState: State = null;

	public var waitFor: Void->Bool;

	public function new(name: String = "Wait", nextState: State = null, waitFor: Void->Bool = null) {
		super(name);
		this.nextState = nextState;
		this.waitFor = waitFor;
	}

	override public function getNextState() {
		return (this.waitFor != null && this.waitFor() == true) ? this.nextState : null;
	}

	override public function copy(): Wait {
		return new Wait(this.name, this.nextState, this.waitFor);
	}
}
