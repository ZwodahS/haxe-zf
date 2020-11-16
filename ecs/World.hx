package common.ecs;

import common.MessageDispatcher;

class World {
    public var entities: Map<Int, Entity>;
    public var systems: List<System>;
    public var dispatcher: MessageDispatcher;

    public function new() {
        this.entities = new Map<Int, Entity>();
        this.systems = new List<System>();
        this.dispatcher = new MessageDispatcher();
    }

    /**
        Reset World to the state after construction.

        1. call reset of all system.
        2. destroy and remove all entities.
        3. clear all messages in dispatcher
    **/
    public function reset() {
        for (s in this.systems) s.reset();
        for (e in this.entities) e.destroy();
        this.entities.clear();
        this.dispatcher.clearMessages();
    }

    /**
        addSystem add a system to the world
    **/
    public function addSystem(system: System) {
        this.systems.add(system);
        system.init(this);
    }

    /**
        removeSystem remove a system from the world
    **/
    public function removeSystem(system: System): Bool {
        return this.systems.remove(system);
    }

    /**
        addEntity adds an entity to this world.
        The entity will be added to all systems if addToSystems if true
    **/
    public function addEntity(ent: Entity, addToSystems = true) {
        var existing = this.entities[ent.id];
        if (existing != null) {
            // if existing, do nothing
            return;
        }
        this.entities[ent.id] = ent;
        @:privateAccess ent.world = this;
        if (addToSystems) {
            for (sys in this.systems) {
                sys.entityAdded(ent);
            }
        }
    }

    /**
        removeEntity remove the entity from this world and all the systems.
    **/
    public function removeEntity(ent: Entity) {
        return this.removeEntityById(ent.id);
    }

    /**
        removeEntity remove the entity by id from this world and all the systems.
    **/
    public function removeEntityById(id: Int) {
        var existing = this.entities[id];
        if (existing == null) {
            return;
        }
        this.entities.remove(id);
        for (sys in this.systems) {
            sys.entityRemoved(existing);
        }
        @:privateAccess existing.world = null;
        this.onEntityRemoved(existing);
    }

    public function removeAllEntities() {
        for (id => e in this.entities) {
            for (sys in this.systems) {
                sys.entityRemoved(e);
            }
            this.onEntityRemoved(e);
            @:privateAccess e.world = null;
        }
        this.entities.clear();
    }

    public function onEntityRemoved(ent: Entity) {}

    /**
        update is the main function that should be called on every update loop
    **/
    public function update(dt: Float) {
        for (sys in this.systems) {
            sys.update(dt);
        }
    }

    public function onEvent(event: hxd.Event) {
        for (sys in this.systems) {
            if (sys.onEvent(event)) {
                break;
            }
        }
    }
}
