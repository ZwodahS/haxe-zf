package common.ecs2d;

import common.ecs2d.Entity;
import common.ecs2d.World;

/**
    Abstract parent class of all System
**/
class System<E:Entity> {

    var world: World<E>;
    public function new() {}

    /**
        inform that an entity is added to the world.
    **/
    public function entityAdded(entity: E) {}
    /**
        inform that an entity is removed from the world.
    **/
    public function entityRemoved(entity: E): E {
        return entity;
    }

    /**
        update loop
    **/
    public function update(dt: Float) {
    }

    /**
        init the system.
        This is called when the system is added to the world.
    **/
    public function init(world: World<E>) {
        this.world = world;
    }

    /**
        handle an event
        return true if the event should stop propagation to other systems
    **/
    public function onEvent(event: hxd.Event): Bool {
        return false;
    }
}
