package zf.ecs.messages;

class ComponentRemoved extends zf.Message {
	public static final MessageType = "ComponentRemoved";

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
		return '[m:ComponentRemoved: ${entity}-${component}]';
	}
}
