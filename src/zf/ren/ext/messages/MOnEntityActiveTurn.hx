package zf.ren.ext.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityActiveTurn extends zf.Message {
	public static final MessageType = "MOnEntityActiveTurn";

	@:dispose("set") public var entity: Entity = null;
	@:dispose public var repeat: Bool = false;

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity, repeat: Bool = false): MOnEntityActiveTurn {
		final m = __alloc__();

		m.entity = entity;
		m.repeat = repeat;

		return m;
	}
}
