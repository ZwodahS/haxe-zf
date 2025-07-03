package zf.ren.ext.player;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnPlayerSet extends zf.Message {
	public static final MessageType = "MOnPlayerSet";

	@:dispose("set") public var prev: Entity = null;
	@:dispose("set") public var next: Entity = null;

	function new() {
		super(MessageType);
	}

	public static function alloc(prev: Entity, next: Entity): MOnPlayerSet {
		final m = __alloc__();

		m.prev = prev;
		m.next = next;

		return m;
	}
	override public function toString() {
		return '[m:${this.type} ${this.prev}->${this.next}]';
	}
}
