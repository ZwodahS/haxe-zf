package zf.ren.core.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MBeforeTakingAction extends zf.Message {
	public static final MessageType = "MBeforeTakingAction";

	@:dispose("set") public var action: Action = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(action: Action): MBeforeTakingAction {
		final m = __alloc__();

		m.action = action;

		return m;
	}
}
