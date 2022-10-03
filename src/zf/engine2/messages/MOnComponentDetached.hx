package zf.engine2.messages;

/**
	Sent when a component is detached from an entity.
**/
class MOnComponentDetached extends zf.Message {
	public static final MessageType = "MOnComponentDetached";

	public var entity: Entity;
	public var component: Component;

	public function new(entity: Entity, component: Component) {
		super(MessageType);
		this.entity = entity;
		this.component = component;
	}

	override public function toString(): String {
		return '[m:ComponentDetached: ${entity} - ${component}]';
	}
}