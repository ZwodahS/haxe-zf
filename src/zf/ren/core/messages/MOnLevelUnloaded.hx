package zf.ren.core.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnLevelUnloaded extends zf.Message {
	public static final MessageType = "MOnLevelUnloaded";

	@:dispose public var level: Level = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(level: Level): MOnLevelUnloaded {
		final m = __alloc__();

		m.level = level;

		return m;
	}
}
