package zf.ren.core.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityMoved extends zf.Message {
	public static final MessageType = "MOnEntityMoved";

	@:dispose("set") public var entity: Entity = null;
	@:dispose("set") public var oldLevel: Level = null;
	@:dispose("set") public var newLevel: Level = null;
	@:dispose public var oldPosition: Point2i;
	@:dispose public var newPosition: Point2i;

	public var newTile(get, never): Tile;

	public function get_newTile(): Tile {
		if (this.newLevel == null || this.newPosition == null) return null;
		return this.newLevel.getTile(this.newPosition.x, this.newPosition.y);
	}

	public var oldTile(get, never): Tile;

	public function get_oldTile(): Tile {
		if (this.oldLevel == null || this.oldPosition == null) return null;
		return this.oldLevel.getTile(this.oldPosition.x, this.oldPosition.y);
	}

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity, oldLevel: Level, oldX: Null<Int>, oldY: Null<Int>, newLevel: Level,
			newX: Null<Int>, newY: Null<Int>): MOnEntityMoved {
		final m = __alloc__();

		m.entity = entity;
		m.oldLevel = oldLevel;
		m.oldPosition = (oldX == null || oldY == null) ? null : [oldX, oldY];
		m.newLevel = newLevel;
		m.newPosition = (newX == null || newY == null) ? null : [newX, newY];

		return m;
	}
}
