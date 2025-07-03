package zf.ren.ext.messages;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnEntityTurnStart extends zf.Message.ResultMessage<Bool> {
	public static final MessageType = "MOnEntityTurnStart";

	@:dispose("set") public var entity: Entity = null;

	// Proxy disrupted to result
	public var disrupted(get, set): Bool;
	inline function get_disrupted(): Bool {
		return this.result;
	}
	public function set_disrupted(v: Bool): Bool {
		return this.result = v;
	}

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity): MOnEntityTurnStart {
		final m = __alloc__();

		m.entity = entity;
		m.disrupted = false;

		return m;
	}
}
