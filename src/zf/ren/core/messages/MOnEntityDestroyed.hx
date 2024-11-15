package zf.ren.core.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityDestroyed extends zf.Message {
	public static final MessageType = "MOnEntityDestroyed";

	@:dispose public var entity: Entity = null;
	@:dispose public var tile: Tile = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity, tile: Tile): MOnEntityDestroyed {
		final m = __alloc__();

		m.entity = entity;
		m.tile = tile;

		return m;
	}
}
