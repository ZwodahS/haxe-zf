package zf.ren.core.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnActionCompleted extends zf.Message {
	public static final MessageType = "MOnActionCompleted";

	@:dispose("set") public var action: Action = null;
	@:dispose("set") public var result: ActionResult = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(action: Action, result: ActionResult): MOnActionCompleted {
		final m = __alloc__();

		m.action = action;
		m.result = result;

		return m;
	}
}
