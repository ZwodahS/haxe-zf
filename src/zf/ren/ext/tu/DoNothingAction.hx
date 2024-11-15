package zf.ren.ext.tu;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class DoNothingAction extends Action {
	@:dispose public var cost: Int = 0;

	function new() {
		super();
	}

	override public function perform(onFinish: ActionResult->Void): Bool {
		final result = ActionResult.alloc();
		result.setValue("cost", this.cost);
		result.setValue("endTurn", true);
		onFinish(result);
		return true;
	}

	public static function alloc(entity: Entity, cost: Int): DoNothingAction {
		final action = DoNothingAction.__alloc__();

		action.entity = entity;
		action.cost = cost;

		return action;
	}
}
