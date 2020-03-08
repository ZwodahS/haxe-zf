package common.ecs;

import common.ecs.World;

/**
  Abstract System class
**/
class System {

    public static final TYPE = "System";
    /**
      type represent the string type of the system
    **/
    public var type(get, null): String;

    public function get_type(): String {
        return TYPE;
    }

    var world: World;

    public function new() {}

    /**
      init function is called when the system is added to the system
    **/
    public function init(world: World) {
        this.world = world;
    }

    /**
      addEntity adds an entity into the system
    **/
    public function addEntity(ent: Entity) {}

    /**
      removeEntity removes an entity into the system
    **/
    public function removeEntity(ent: Entity): Entity {
        return ent;
    }

    /**
      update is the main function called by the world.
    **/
    public function update(dt: Float) {}
}
