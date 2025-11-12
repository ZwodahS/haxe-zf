package zf.ren.ext.td;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MGetEntityTurnDelay extends zf.Message.ResultMessage<Int> {
	public static final MessageType = "MGetEntityTurnDelay";

	@:dispose("set") public var entity: Entity = null;

	// Proxy delay to result
	public var delay(get, set): Int;
	inline function get_delay(): Int {
		return this.result;
	}
	public function set_delay(v: Int): Int {
		return this.result = v;
	}

	function new() {
		super(MessageType);
	}

	public static function alloc(entity: Entity, delay: Int): MGetEntityTurnDelay {
		final m = __alloc__();

		m.entity = entity;
		m.delay = delay;

		return m;
	}
}
