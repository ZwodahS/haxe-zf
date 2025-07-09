package zf.ren.core;

import zf.ren.core.components.LocationComponent;

typedef LinePoint2i = List<Point2i>;

enum BlockType {
	NoBlock; // not blocked by diagonal
	FullyBlocked; // fully blocked by 1 diagonal tile
	PartiallyBlocked; // Partially blocked by 1 diagonal tile, requires 2 tile to fully block it.
}

/**
	Level is a data container for a 2D finite floor.
**/
#if !macro @:build(zf.macros.Serialise.build()) #end
class Level implements EntityContainer implements Serialisable implements Disposable {
	/**
		A string identifier for this level
	**/
	@:serialise public var id(default, null): String = "";

	/**
		The readonly grid that can be used to get data
		Do not modify directly.
	**/
	public var tiles: Vector2D<Tile>;

	/**
		size of the level
	**/
	public var size(get, never): Point2i;

	public function get_size(): Point2i {
		return [this.tiles.size.x, this.tiles.size.y];
	}

	/**
		Entities on the level.
		Do not modify directly.
	**/
	public var entities: Entities<Entity>;

	/**
		create a new level

		@param size the size of the level
		@param id an id to overwrite the default id generation
	**/
	public function new(width: Int, height: Int, id: String) {
		this.tiles = new Vector2D<Tile>(width, height, null);
		this.id = id;
		this.entities = new Entities<Entity>();
	}

	/**
		place an entity into this position on this level

		@param e the entity to be placed
		@param x the position to place into
		@param y the position to place into

		@return true if successful, false otherwise
	**/
	public function placeEntity(e: Entity, x: Int, y: Int): Bool {
		if (!canPlaceEntity(e, x, y)) return false;
		final tile = this.tiles.get(x, y);
		if (tile == null) return false;
		if (!tile.addEntity(e)) return false;

		/**
			Wed 14:40:31 13 Nov 2024
			not sure what happen if the entity move from one level to another.
		**/
		final location = LocationComponent.get(e);
		location.level = this;

		if (!this.entities.exists(e)) {
			this.entities.add(e);
			onEntityAdded(e, tile);
		}

		return true;
	}

	function onEntityAdded(e: Entity, tile: Tile) {}

	/**
		check if an entity can be placed in this position

		@param e the entity to be placed
		@param x the position to be placed into
		@param y the position to be placed into

		@return true if possible, false otherwise
	**/
	public function canPlaceEntity(e: Entity, x: Int, y: Int): Bool {
		final tile = this.tiles.get(x, y);
		return tile == null ? false : tile.canAddEntity(e);
	}

	/**
		Move entity to a new position

		This only work if the entity is already currently on the level.

		@param entity the Entity to move
		@param x the position to move to
		@param y the position to move to
		@param lc the location component of the entity.
		@return true if the move is successful, false otherwise
	**/
	public function moveEntity(entity: Entity, x: Int, y: Int, ?lc: LocationComponent): Bool {
		if (lc == null) lc = LocationComponent.get(entity);
		if (lc == null || lc.level != this) return false;

		final toTile = this.tiles.get(x, y);
		if (toTile == null) return false;

		final fromTile = lc.tile;

		// moving to the same tile
		if (fromTile == toTile) return false;

		toTile.addEntity(entity);
#if debug
		/**
			There is a weird bug that keep failing the assertions
		**/
		if (fromTile.hasEntity(entity) == true) {
			Logger.debug('assertion fail: fromTile.hasEntity == true');
			Logger.debug('moving from tile: ${fromTile.x}, ${fromTile.y}');
			Logger.debug(' entities on tile');
			for (e in fromTile.entities) {
				trace("-", e.typeId);
			}
			if (toTile != null) {
				Logger.debug('moving to tile: ${toTile.x}, ${toTile.y}');
				Logger.debug(' entities on tile');
				for (e in toTile.entities) {
					trace("-", e.typeId);
				}
			}
		}
#end
		Assert.assert(!fromTile.hasEntity(entity), {id: entity?.typeId});
		Assert.assert(toTile.hasEntity(entity), {id: entity?.typeId});
		onEntityMoved(entity, fromTile, toTile);

		return true;
	}

	function onEntityMoved(entity: Entity, fromTile: Tile, toTile: Tile) {}

	/**
		Remove entity from this level

		@param entity the Entity to remove
		@param lc the location component of the entity

		@return true if entity is on the level, false otherwise
	**/
	public function removeEntity(entity: Entity, ?lc: LocationComponent): Bool {
		if (lc == null) lc = LocationComponent.get(entity);
		if (lc == null || lc.level != this || lc.tile == null) return false;

		final fromTile = lc.tile;
		lc.tile.removeEntity(entity, lc);

		if (this.entities.exists(entity)) {
			this.entities.remove(entity);
			onEntityRemoved(entity, fromTile);
		}

		return true;
	}

	function onEntityRemoved(e: Entity, tile: Tile) {}

	/**
		Get a random position on the level to place an entity

		@param e Entity to be placed
		@param r the randomizer
		@param maxTries the maximum number of tries to place the entity

		@return the tile that can be placed on
	**/
	public function getRandomPlaceablePosition(e: Entity, r: hxd.Rand = null, maxTries: Int = 10): Tile {
		r = r ?? zf.hxd.Rand.r();
		var tries = 0;
		final size = this.size;

		// TODO: while this is easy to implement, we need a better one that spawn in a 3x3 or 5x5 area.
		while (tries < maxTries) {
			tries += 1;
			final x = r.randomInt(size.x);
			final y = r.randomInt(size.y);
			if (canPlaceEntity(e, x, y)) return this.tiles.get(x, y);
		}
		return null;
	}

	/**
		Get a Tile on the level

		@param x the x position
		@param y the y position

		@return the tile. null if not in bound
	**/
	inline public function getTile(x: Int, y: Int): Tile {
		return this.tiles.get(x, y);
	}

	/**
		Set the tile

		@param x the x position
		@param y the y position

		@return previous tile in the position
	**/
	public function setTile(x: Int, y: Int, t: Tile): Tile {
		final prevTile = this.tiles.get(x, y);
		onTileUnset(prevTile, x, y);
		this.tiles.set(x, y, t);
		onTileSet(t, x, y);
		return prevTile;
	}

	function onTileUnset(t: Tile, x: Int, y: Int) {
		if (t == null) return;
		t.level = null;
		for (id => e in t.entities) {
			final lc = LocationComponent.get(e);
			if (lc == null) continue;
			lc.level = null;
			this.entities.remove(e);
		}
	}

	function onTileSet(t: Tile, x: Int, y: Int) {
		if (t == null) return;
		t.level = this;
		for (id => e in t.entities) {
			final lc = LocationComponent.get(e);
			if (lc == null) continue;
			lc.level = this;
			this.entities.add(e);
		}
	}

	/**
		The distance between 2 points on the level
	**/
	public function distance(pt1: Point2i, pt2: Point2i): Int {
		var diff = pt1 - pt2;
		return Math.iMax([Math.iAbs(diff.x), Math.iAbs(diff.y)]);
	}

	public function toString(): String {
		return '(Level:${id})';
	}

	/** Iterator functions **/
	/**
		Level Iterators
	**/
	public function iterateLevelFromCenter(centerX: Int, centerY: Int, r: hxd.Rand, minDistance: Int = 1,
			maxDistance: Int = -1): TilesIterator {
		return new TilesIterator(this, centerX, centerY, r, minDistance, maxDistance);
	}

	/** Utility Functions **/
	/**
		Map the tile from 1 value to another value and return
	**/
	public function mapTile<T>(f: Tile->T, nullValue: T): Vector2D<T> {
		var v = new Vector2D<T>(this.tiles.size.x, this.tiles.size.y, nullValue);
		for (pt => t in this.tiles.iterateYX()) {
			v.set(pt.x, pt.y, f(t));
		}
		return v;
	}

	public function getRandomTile(r: hxd.Rand, f: Tile->Bool = null): Tile {
		final x = r.randomInt(this.tiles.size.x);
		final y = r.randomInt(this.tiles.size.y);
		for (t in iterateLevelFromCenter(x, y, r, 0)) {
			if (f == null || f(t)) return t;
		}
		return null;
	}

	public function collectEntities(entities: Entities<Entity>) {
		for (e in this.entities) entities.add(e);
	}

	public function dispose() {}

	// ---- Save / Load ----
	public function toStruct(context: SerialiseContext): Dynamic {
		final sf = this.__toStruct__(context, {});
		sf.width = this.tiles.width;
		sf.height = this.tiles.height;

		final tiles: Array<Dynamic> = [];

		for (pt => tile in this.tiles.iterateYX()) {
			final sf = tile.toStruct(context);
			tiles.push(sf);
		}
		sf.tiles = tiles;

		return sf;
	}

	public function loadStruct(context: SerialiseContext, struct: Dynamic): Level {
		final tiles: Array<Dynamic> = struct.tiles;
		Assert.assert(tiles.length == this.tiles.width * this.tiles.height);

		var ind = 0;
		for (pt => tile in this.tiles.iterateYX()) {
			final tileSF = tiles[ind++];
			tile.loadStruct(context, tileSF);
		}

		return this;
	}
}
