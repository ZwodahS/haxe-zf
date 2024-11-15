package zf.ren.ext.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityActiveTurn extends zf.Message {
	public static final MessageType = "MOnEntityActiveTurn";

	@:dispose public var entity: Entity = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity): MOnEntityActiveTurn {
		final m = __alloc__();

		m.entity = entity;

		return m;
	}
}
