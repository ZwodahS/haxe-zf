package zf.ren.core;

/**
	The core world object that stores and manage all the systems and entity.

	Assumption:

	1. updater

	if updater.count() > 0, it means that the world is blocked by animations, aka isAnimating.
	If we need to wait for animations to finish, then we can check it by calling isAnimating.
	Non-blocking animations should not use this updater.
**/
class World extends zf.engine2.World {
	public var isAnimating(get, never): Bool;

	inline public function get_isAnimating(): Bool {
		return this.updater.count > 0;
	}

	/**
		Store all the loaded levels.
	**/
	public var loadedLevels: Map<String, Level>;

	/**
		Load a level.

		@param level level to load

		When a level is loaded, all the entities will also be added
	**/
	public function loadLevel(level: Level) {
		if (this.loadedLevels.exists(level.id)) return;

		for (xy => tile in level.tiles.iterateYX()) {
			if (tile == null) continue;
			for (e in tile.entities) {
				this.registerEntity(e);
			}
		}
		this.loadedLevels.set(level.id, level);
	}

	/**
		Unload a level
		This will unload all entities
		If level is not loaded, nothing happens

		@param level level to unload.
	**/
	public function unloadLevel(level: Level) {
		if (this.loadedLevels.exists(level.id) == false) return;
		for (xy => tile in level.tiles.iterateYX()) {
			if (tile == null) continue;
			for (e in tile.entities) {
				this.unregisterEntity(e);
			}
		}
		this.loadedLevels.remove(level.id);
	}

	inline public function isLoaded(level: Level): Bool {
		return this.loadedLevels.exists(level.id);
	}

	public function new() {
		super();
		this.loadedLevels = [];
	}

	// ---- Entity movement code ---- //

	/**
		Generic method to move entity into a level.

		No assumption is made on if the entity is already in another level.
		This does not perform any checks.

		If an entity is already on the level, this will also work, just a bit more costly.
		The method moveEntity will be better

		@param entity Entity to move
		@param level Level to move to
		@param x the position to move into
		@param y the position to move into
		@param autoload automatically load the level if it is not yet loaded.
	**/
	public function moveEntityIntoLevel(entity: Entity, level: Level, x: Int, y: Int, autoload: Bool = true): Bool {
		if (loadedLevels.exists(level.id) == false) {
			if (autoload == false) return false;
			loadLevel(level);
		}

		this.registerEntity(entity);

		final lc = LocationComponent.get(entity);

		// keep the previous value
		final prevLevel = lc.level;
		final prevX: Null<Int> = lc.x;
		final prevY: Null<Int> = lc.y;
		final prevTile = lc.tile;

		if (prevLevel != null) prevLevel.removeEntity(entity, lc);
		level.placeEntity(entity, x, y);

		this.dispatcher.dispatch(MOnEntityMoved.alloc(entity, prevLevel, prevX, prevY, level, x, y)).dispose();

		return true;
	}

	/**
		Generic method to move entity within a level

		No assumptions or checks are made.
		@param entity Entity to move
		@param x the position to move to
		@param y the position to move to
	**/
	public function moveEntity(entity: Entity, x: Int, y: Int, dispatch: Bool = true): Bool {
		final lc = LocationComponent.get(entity);
		if (lc == null || lc.level == null) return false;

		final prevX = lc.x;
		final prevY = lc.y;

		if (!lc.level.moveEntity(entity, x, y)) return false;

		if (dispatch == true) {
			this.dispatcher.dispatch(MOnEntityMoved.alloc(entity, lc.level, prevX, prevY, lc.level, x, y)).dispose();
		}

		return true;
	}

	/**
		Remove the entity from the level.

		Entity is still kept around and needs to be unregistered
	**/
	public function removeEntityFromLevel(entity: Entity): Bool {
		final lc = LocationComponent.get(entity);
		if (lc == null || lc.level == null) return false;

		final prevLevel = lc.level;
		final prevX = lc.x;
		final prevY = lc.y;

		prevLevel.removeEntity(entity, lc);

		if (this.isDisposing == false) {
			this.dispatcher.dispatch(MOnEntityMoved.alloc(entity, prevLevel, prevX, prevY, null, null, null)).dispose();
		}

		return true;
	}

	/**
		Destroy the entity.
	**/
	public function destroyEntity(entity: Entity) {
		final lc = LocationComponent.get(entity);
		final tile = lc?.tile;
		if (tile != null) {
			removeEntityFromLevel(entity);
			this.dispatcher.dispatch(MOnEntityDestroyed.alloc(entity, tile));
		}
		this.unregisterEntity(entity);
	}

	/**
		Overried unregister entity to completely remove it from level just in case
	**/
	override public function unregisterEntity(e: zf.engine2.Entity) {
		removeEntityFromLevel(e);
		super.unregisterEntity(e);
	}

	/**
		Entity perform an action

		Assumption: The action will be disposed once it is completed.
	**/
	public function performAction(action: Action): Bool {
		this.dispatcher.dispatch(MBeforeTakingAction.alloc(action)).dispose();

		/**
			This is a call back because there is a need to wait for animations to finish
		**/
		final success = action.perform((result) -> {
			onActionCompleted(action, result);
			action.dispose();
			result.dispose();
		});

		return success;
	}

	function onActionCompleted(action: Action, result: ActionResult) {
		if (result == null) return;
		this.dispatcher.dispatch(MOnActionCompleted.alloc(action, result)).dispose();
	}
}
