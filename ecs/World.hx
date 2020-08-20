package common.ecs;

class World<E: Entity> {
    public var entities: Map<Int, E>;
    public var systems: List<System<E>>;

    public function new() {
        this.entities = new Map<Int, E>();
        this.systems = new List<System<E>>();
    }

    public function reset() {
        /**
            remove all the entities and reset all the systems.

            We have 2 options.
            1. just delete the world and create a new world
            2. reset the world.

            We could delete the world, but we also need the world to destroy all the listeners etc.
            The effort in doing that is probably the same as resetting the world, hence we might as well do that.
        **/

        for (s in this.systems) s.reset();
        for (e in this.entities) e.destroy();
        this.entities.clear();
    }

    /**
        addSystem add a system to the world
    **/
    public function addSystem(system: System<E>) {
        this.systems.add(system);
        system.init(this);
    }

    /**
        removeSystem remove a system from the world
    **/
    public function removeSystem(system: System<E>): Bool {
        return this.systems.remove(system);
    }

    /**
        addEntity adds an entity to this world.
        The entity will be added to all systems if addToSystems if true
    **/
    public function addEntity(ent: E, addToSystems = true) {
        var existing = this.entities[ent.id];
        if (existing != null) {
            // if existing, do nothing
            return;
        }
        this.entities[ent.id] = ent;
        if (addToSystems) {
            for (sys in this.systems) {
                sys.entityAdded(ent);
            }
        }
    }

    /**
        removeEntity remove the entity from this world and all the systems.
    **/
    public function removeEntity(ent: E) {
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
        this.onEntityRemoved(existing);
    }

    public function removeAllEntities() {
        for (id => e in this.entities) {
            for (sys in this.systems) {
                sys.entityRemoved(e);
            }
            this.onEntityRemoved(e);
        }
        this.entities.clear();
    }

    public function onEntityRemoved(ent: E) {}

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
