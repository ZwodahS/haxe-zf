package common.ecs;

/**
    An component of the entity
**/
class Component {
    public static final TYPE = "Component";

    public var type(get, never): String;

    public function new() {}

    public function get_type(): String {
        return TYPE;
    }

    public var entity(default, set): Entity;

    public function set_entity(e: Entity): Entity {
        this.entity = e;
        return e;
    }
}
