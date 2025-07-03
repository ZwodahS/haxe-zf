package zf.ren.ext.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityHealthChanged extends zf.Message {
	public static final MessageType = "MOnEntityHealthChanged";

	@:dispose("set") public var entity: Entity = null;
	@:dispose public var prev: Int = 0;
	@:dispose public var next: Int = 0;

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity, prev: Int, next: Int): MOnEntityHealthChanged {
		final m = __alloc__();

		m.entity = entity;
		m.prev = prev;
		m.next = next;

		return m;
	}
	override public function toString() {
		return '[m:${this.type} ${this.prev}->${this.next}]';
	}
}
