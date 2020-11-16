package common.ecs.messages;

class ComponentRemoved extends common.Message {
    public static final Type = "ComponentRemoved";

    override public function get_type(): String {
        return Type;
    }

    public var entity: Entity;
    public var component: Component;

    public function new(entity: Entity, component: Component) {
        super();
        this.entity = entity;
        this.component = component;
    }
}
