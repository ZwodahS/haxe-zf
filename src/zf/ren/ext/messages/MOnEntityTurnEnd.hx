package zf.ren.ext.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityTurnEnd extends zf.Message {
	public static final MessageType = "MOnEntityTurnEnd";

	@:dispose public var entity: Entity = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity): MOnEntityTurnEnd {
		final m = __alloc__();

		m.entity = entity;

		return m;
	}
}
