package zf.engine2;

import zf.MessageDispatcher;

/**
	@stage:stable

	Abstract parent class of all System.
**/
class System {
	/**
		The world containing this System
	**/
	var __world__(default, null): World;

	/**
		Alias to the dispatcher in world
	**/
	public var dispatcher(get, never): MessageDispatcher;

	inline function get_dispatcher() {
		return this.__world__ == null ? null : this.__world__.dispatcher;
	}

	public function new() {}

	/**
		init the system.
		This is called when the system is added to the world.
	**/
	public function init(world: World) {
		this.__world__ = world;
	}

	/**
		handle an event
		return true if the event should stop propagation to other systems
	**/
	public function onEvent(event: hxd.Event): Bool {
		return false;
	}

	/**
		reset the system to the same state after constructor
	**/
	public function reset() {}

	/**
		Dispose the system data
	**/
	public function dispose() {}

	/**
		update loop
	**/
	public function update(dt: Float) {}

	public function onEntityAdded(e: Entity) {}

	public function onEntityRemoved(e: Entity) {}
}
