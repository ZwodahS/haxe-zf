package zf.engine2;

import zf.MessageDispatcher;

/**
	@stage:stable
**/
class World {

	public var isDisposing: Bool = false;
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

		Fri 13:19:00 15 Nov 2024
		We are moving most of the non-blocking animations and updating to use zf.ef.
		This means for the most part, non-blocking animations should not use this updater.
		We will only use this for blocking updating.
	**/
	public final updater: zf.up.Updater;

	/**
		A default rand

		Note
		If a stable number gen is needed and wants to be store, create a new separately.
		This should ideally only be used for animations.
	**/
	public var r: hxd.Rand;

	public function new() {
		this.__systems__ = new List<System>();
		this.__entities__ = new Entities<Entity>();
		this.updater = new zf.up.Updater();
		this.dispatcher = new MessageDispatcher();
		this.r = new hxd.Rand(Random.int(0, zf.Constants.SeedMax));
#if dispatchMessages
		this.dispatcher.onAfterMessage = (m) -> {
			Logger.debug('${m} ${m.delta} (${zf.StringUtils.formatFloat(m.delta / 0.016, 2)} frame)', "[Messages]");
		}
#end
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
		this.isDisposing = true;
		for (e in this.__entities__) e.dispose();
		for (s in this.__systems__) s.dispose();
	}

	// ---- Entities ---- //
	public function registerEntity(e: Entity) {
		if (this.__entities__.exists(e)) return;
		this.__entities__.add(e);
		e.__world__ = this;
		for (s in this.__systems__) s.onEntityAdded(e);
	}

	public function unregisterEntity(e: Entity) {
		if (this.__entities__.exists(e) == false) return;
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
		for (sys in this.__systems__) sys.update(dt);
		this.updater.update(dt);
	}

	// ---- Event handling ---- //
	public function onEvent(event: hxd.Event): Bool {
		for (sys in this.__systems__) {
			if (sys.onEvent(event)) return true;
		}
		return false;
	}
}
