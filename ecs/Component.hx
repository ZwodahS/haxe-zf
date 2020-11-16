package common.ecs;

/**
    Generic Component object
**/
class Component {
    public var type(get, never): String;

    public function get_type(): String {
        return 'Component';
    }

    public function new() {}
}
