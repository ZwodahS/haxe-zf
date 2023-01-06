package zf.engine2.messages;

/**
	@stage:stable

	Sent when a component is attached to an entity.
**/
class MOnComponentAttached extends zf.Message {
	public static final MessageType = "MOnComponentAttached";

	public var entity: Entity;
	public var component: Component;

	public function new(entity: Entity, component: Component) {
		super(MessageType);
		this.entity = entity;
		this.component = component;
	}

	override public function toString(): String {
		return '[m:ComponentAttached: ${entity} + ${component}]';
	}
}
