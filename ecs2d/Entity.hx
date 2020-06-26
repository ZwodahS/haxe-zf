package common.ecs2d;

/**
    Generic Entity object.
**/
class Entity extends h2d.Layers {
    public var id(default, null): Int; // id is only set during construction

    private static var idCounter: Int = 0; // global id counter for entity

    public function new() {
        super();
        this.id = idCounter++;
    }

    override public function toString(): String {
        return 'Entity: ${this.id}';
    }
}
