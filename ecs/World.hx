
package common.ecs;

import common.ecs.Entity;
import common.ecs.System;

class World {
    private var entities: Map<Int, Entity>;
    private var systems: List<System>;

    public function new() {
        this.entities = new Map<Int, Entity>();
        this.systems = new List<System>();
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
    public function addEntity(ent: Entity, addToSystems=true) {
        var existing = this.entities[ent.id];
        if (existing != null) {
            // if existing, do nothing
            return;
        }
        this.entities[ent.id] = ent;
        if (addToSystems) {
            for (sys in this.systems) {
                sys.addEntity(ent);
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
        if (existing != null) {
            return;
        }
        this.entities.remove(id);
        for (sys in this.systems) {
            sys.removeEntity(existing);
        }
    }

    /**
      update is the main function that should be called on every update loop
    **/
    public function update(dt: Float) {
        for (sys in this.systems) {
            sys.update(dt);
        }
    }
}
