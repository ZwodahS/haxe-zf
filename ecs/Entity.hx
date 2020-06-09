package common.ecs;

/**
    An entity of the world.
**/
class Entity extends h2d.Layers {
    /**
        The id of the entity. This is only set on creation.
    **/
    public var id(default, null): Int;

    /**
        Store the list of components of the entity
    **/
    var components: Map<String, Component>;

    /**
        The mailbox used to communicate between systems
    **/
    private function new(id: Int) {
        super();
        this.id = id;
        this.components = new Map<String, Component>();
    }

    /**
        hasComponent check if the entity has a component of this name
    **/
    public function hasComponent(name: String): Bool {
        return this.components.exists(name);
    }

    /**
        getComponent returns the component given a name
    **/
    public function getComponent(name: String = ""): Component {
        return this.components.get(name);
    }

    /**
        addComponent adds a component to the entity.
    **/
    public function addComponent(component: Component, name: String = null) {
        if (name == null) {
            name = component.type;
        }

        var existing = this.getComponent(name);
        this.components[name] = component;
        if (existing != null) {
            existing.entity = null;
        }
        component.entity = this;
    }

    public function addComponents(components: Array<Component>) {
        for (component in components) {
            this.addComponent(component, component.type);
        }
    }

    /**
        removeComponent remove a component with the given name from the entity
    **/
    public function removeComponent(name: String) {
        var existing = this.getComponent(name);
        if (existing == null) {
            return;
        }
        this.components.remove(name);
    }

    private static var counter: Int = 0;

    public static function newEntity(): Entity {
        return new Entity(newId());
    }

    public static function newId(): Int {
        return counter++;
    }

    override public function toString(): String {
        return 'Entity: ${this.id}';
    }
}
