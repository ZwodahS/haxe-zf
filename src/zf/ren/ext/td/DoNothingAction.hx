package zf.ren.ext.td;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class DoNothingAction extends Action {
	function new() {
		super();
	}

	override public function perform(onFinish: ActionResult->Void): Bool {
		final result = ActionResult.alloc();
		onFinish(result);
		return true;
	}

	public static function alloc(entity: Entity): DoNothingAction {
		final action = DoNothingAction.__alloc__();

		action.entity = entity;

		return action;
	}
}
