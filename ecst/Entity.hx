package common.ecst;

/**
    Generic Entity object.
**/
class Entity {
    public var id(default, null): Int; // id is only set during construction

    private static var idCounter: Int = 0; // global id counter for entity

    public function new(id: Null<Int> = null) {
        if (id == null) {
            this.id = idCounter++;
        } else {
            this.id = id;
        }
    }

    public function destroy() {}

    public function toString(): String {
        return 'Entity: ${this.id}';
    }
}
