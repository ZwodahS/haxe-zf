package zf.engine2.messages;

/**
	@stage:stable

	Sent when a component is detached from an entity.
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class MOnComponentDetached extends zf.Message {
	public static final MessageType = "MOnComponentDetached";

	@:dispose("set") public var entity: Entity = null;
	@:dispose("set") public var component: Component = null;

	function new() {
		super(MessageType);
	}

	override public function toString(): String {
		return '[m:ComponentDetached: ${entity} - ${component}]';
	}

	public static function alloc(entity: Entity, component: Component): MOnComponentDetached {
		final m = __alloc__();

		m.entity = entity;
		m.component = component;

		return m;
	}
}
