package zf.ecs.messages;

class ComponentAttached extends zf.Message {
	public static final MessageType = "ComponentAttached";

	override public function get_type(): String {
		return MessageType;
	}

	public var entity: Entity;
	public var component: Component;

	public function new(entity: Entity, component: Component) {
		super();
		this.entity = entity;
		this.component = component;
	}

	override public function toString(): String {
		return '[m:ComponentAttached: ${entity}+${component}]';
	}
}
