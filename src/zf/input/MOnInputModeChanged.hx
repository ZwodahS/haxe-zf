package zf.input;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnInputModeChanged extends zf.Message {
	public static final MessageType = "MOnInputModeChanged";

	@:dispose public var mode: InputMode = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(mode: InputMode): MOnInputModeChanged {
		final m = __alloc__();

		m.mode = mode;

		return m;
	}
}
