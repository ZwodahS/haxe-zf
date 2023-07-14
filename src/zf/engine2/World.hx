package zf.engine2;

import zf.MessageDispatcher;

/**
	@stage:stable
**/
class World {
	/**
		List of systems.

		The update function of the systems will be called in the order that they are added.
	**/
	final __systems__: List<System>;

	/**
		The message dispatcher assigned to the world.
	**/
	public var dispatcher(default, null): MessageDispatcher;

	/**
		Entities
	**/
	final __entities__: Entities<Entity>;

	/**
		The default updater.
	**/
	public final updater: zf.up.Updater;

	/**
		A default rand
	**/
	public var r: hxd.Rand;

	public function new() {
		this.__systems__ = new List<System>();
		this.__entities__ = new Entities<Entity>();
		this.updater = new zf.up.Updater();
		this.dispatcher = new MessageDispatcher();
		this.r = new hxd.Rand(Random.int(0, zf.Constants.SeedMax));
	}

	/**
		Reset World to the state after construction.

		1. call reset of all system.
		2. destroy and remove all entities.
		3. clear all messages in dispatcher
	**/
	public function reset() {
		for (s in this.__systems__) s.reset();
		this.dispatcher.clearMessages();
		this.__entities__.clear();
	}

	/**
		Destroy world
	**/
	public function dispose() {
		for (e in this.__entities__) e.dispose();
		for (s in this.__systems__) s.dispose();
	}

	// ---- Entities ---- //
	public function registerEntity(e: Entity) {
		this.__entities__.add(e);
		e.__world__ = this;
		for (s in this.__systems__) s.onEntityAdded(e);
	}

	public function unregisterEntity(e: Entity) {
		this.__entities__.remove(e);
		for (s in this.__systems__) s.onEntityRemoved(e);
		e.__world__ = null;
	}

	// ---- Systems ---- //

	/**
		addSystem add a system to the world
	**/
	public function addSystem(system: System) {
		this.__systems__.add(system);
		system.init(this);
	}

	/**
		removeSystem remove a system from the world
	**/
	public function removeSystem(system: System): Bool {
		final success = this.__systems__.remove(system);
		if (system != null) system.dispose();
		return success;
	}

	/**
		update is the main function that should be called on every update loop
	**/
	public function update(dt: Float) {
		for (entity in this.__entities__) entity.update(dt);
		for (sys in this.__systems__) sys.update(dt);
		this.updater.update(dt);
	}

	// ---- Event handling ---- //
	public function onEvent(event: hxd.Event) {
		for (sys in this.__systems__) {
			if (sys.onEvent(event)) break;
		}
	}
}
