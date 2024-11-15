package zf.ren.core;

/**
	Action should not be used directly.

	Instead it should be extended.
**/
class Action implements Disposable {
	public var type(get, never): String;

	inline public function get_type(): String {
		return "Action";
	}

	public var entity: Entity = null;

	function new() {}

	public function dispose() {
		this.entity = null;
	}

	/**
		Perform the action and call onFinish once the action is completed.

		@param onFinish
			if an integer is provided, it will be the cost of the action.
			If it is null, the action is considered to have not happened.

		@return true if the action is successful, false otherwise.
			The return tells the performer if the action is successful, not if the action is completed.
	**/
	public function perform(onFinish: ActionResult->Void): Bool {
		return false;
	}
}
