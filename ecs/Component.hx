
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
}
