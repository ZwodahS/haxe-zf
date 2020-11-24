package zf.ecst;

/**
    Abstract parent class of all System
**/
class System<E: Entity> {
    public function new() {}

    /**
        inform that an entity is added to the world.
    **/
    public function entityAdded(entity: E) {}

    /**
        inform that an entity is removed from the world.
    **/
    public function entityRemoved(entity: E) {}

    /**
        update loop
    **/
    public function update(dt: Float) {}

    /**
        init the system.
        This is called when the system is added to the world.
    **/
    public function init(world: World<E>) {}

    /**
        handle an event
        return true if the event should stop propagation to other systems
    **/
    public function onEvent(event: hxd.Event): Bool {
        return false;
    }

    public function reset() {
        /**
            reset the system to the same state after constructor
        **/
    }
}
