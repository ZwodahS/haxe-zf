package zf.ren.core.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnLevelLoaded extends zf.Message {
	public static final MessageType = "MOnLevelLoaded";

	@:dispose public var level: Level = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(level: Level): MOnLevelLoaded {
		final m = __alloc__();

		m.level = level;

		return m;
	}
}
