package zf.ren.core;

import zf.ren.core.components.LocationComponent;
import zf.serialise.*;

typedef TileSF = {
	public var entities: Array<String>;
}

/**
	Tile is a data container for a grid on the map
**/
#if !macro @:build(zf.macros.Serialise.build()) #end
#if !macro @:build(zf.macros.ObjectPool.build(false)) #end
class Tile implements Serialisable implements Disposable {
	public static final MaxDistance = 0x10000000;

	/**
		The type representing the tile
	**/
	@:dispose @:serialise public var type(default, null): String = null;

	/**
		The x position of the tile
	**/
	@:dispose public var x(default, null): Int = 0;

	/**
		The y position of the tile
	**/
	@:dispose public var y(default, null): Int = 0;

	/**
		Store all the entities on the Tile.
		Do not modify directly
	**/
	@:dispose("func", "clear") public var entities: Entities<Entity>;

	/**
		Store the level that the tile is in
		Should only be set by Level
	**/
	@:dispose("set") public var level: Level = null;

	/**
		A metadata map to store anything.
	**/
	@:dispose("func", "clear") public var metadata: Map<String, Dynamic>;

	/**
		Create a empty tile object
	**/
	public function new() {
		this.entities = new Entities<Entity>();
		this.metadata = new Map<String, Dynamic>();
	}

	/**
		@param x the x position of this tile on the level
		@parma y the y position of this tile on the level
		@param type the type representing the tile
	**/
	function init(x: Int, y: Int, type: String) {
		this.type = type;
		this.x = x;
		this.y = y;
	}

	/**
		Add Entity to the tile.

		@param e entity to add

		@return true if successfully added, false if fail or entity already exists.
	**/
	public function addEntity(e: Entity): Bool {
		if (canAddEntity(e) == false) return false;

		final location = LocationComponent.get(e);
		if (location == null) return false;

		if (location.tile != null) {
			// we should never call add Entity when the entity is in another level
			Assert.assert(location.level == this.level);
			location.tile.internalRemoveEntity(e);
		}
		internalAddEntity(e, location);

		return true;
	}

	public function findEntity(f: (Entity) -> Bool): Entity {
		for (e in this.entities) {
			if (f(e) == true) return e;
		}
		return null;
	}

	function internalAddEntity(e: Entity, ?lc: LocationComponent) {
		if (lc == null) lc = LocationComponent.get(e);

		this.entities.add(e);

		lc.x = this.x;
		lc.y = this.y;
	}

	public function placeEntity(e: Entity): Bool {
		if (this.level == null) return false;
		return this.level.placeEntity(e, this.x, this.y);
	}

	/**
		Remove Entity from the tile

		@param e entity to remove

		@return true if successfully removed, false if fail or entity does not exists.
	**/
	public function removeEntity(e: Entity, ?lc: LocationComponent): Bool {
		if (this.entities.exists(e) == false) return false;

		internalRemoveEntity(e);

		lc = lc == null ? LocationComponent.get(e) : lc;
		Assert.assert(lc != null);

		lc.x = null;
		lc.y = null;
		lc.level = null;

		return true;
	}

	inline public function hasEntity(e: Entity): Bool {
		return this.entities.exists(e);
	}

	/**
		Internally remove entity from this tile.

		This is to be used by other Tile object for when entity is moved added into a tile
		before removing from the old tile.

		Override this to add more functionality.
	**/
	function internalRemoveEntity(e: Entity) {
		this.entities.remove(e);
	}

	/**
		Check if this entity can be added to this tile.

		@param e the entity to check.

		@return true if the entity can be added, false otherwise.
	**/
	public function canAddEntity(e: Entity): Bool {
		return true;
	}

	public function toString(): String {
		return '(Tile:${this.x},${this.y})';
	}

	public function getTileInDirection(direction: Direction, range: Int = 1): Tile {
		if (this.level == null) return null;

		final targetPosition: Point2i = [this.x, this.y];
		for (_ in 0...range) {
			targetPosition += direction;
		}
		final tile = this.level.getTile(targetPosition.x, targetPosition.y);
		targetPosition.dispose();

		return tile;
	}

	public function getDirectionOfTile(tile: Tile, adjacentOnly: Bool = true): zf.Direction {
		if (adjacentOnly && isAdjacentTo(tile) == false) return null;
		return zf.Direction.fromXY(tile.x - this.x, tile.y - this.y);
	}

	public function getAdjacentTiles(): Array<Tile> {
		return this.level.tiles.getAdjacent(this.x, this.y);
	}

	public function getTilesAround(grid: Vector2D<Tile> = null, range: Int = 1): Vector2D<Tile> {
		if (grid == null) grid = new Vector2D<Tile>(range * 2 + 1, range * 2 + 1, null);
		if (this.level == null) return grid;
		for (y in -range...range + 1) {
			for (x in -range...range + 1) {
				grid.set(x + range, y + range, this.level.getTile(this.x + x, this.y + y));
			}
		}
		return grid;
	}

	public function isAdjacentTo(tile: Tile): Bool {
		if (this.level != tile.level) return false;
		final pt1 = Point2i.alloc(this.x, this.y);
		final pt2 = Point2i.alloc(tile.x, tile.y);
		final isAdjacent = pt1.isAdjacent(pt2);
		pt1.dispose();
		pt2.dispose();
		return isAdjacent;
	}

	public function distanceFrom(tile: Tile): Int {
		if (tile.level != this.level) return MaxDistance;

		final pt1: Point2i = Point2i.alloc(this.x, this.y);
		final pt2: Point2i = Point2i.alloc(tile.x, tile.y);
		final distance = tile.level.distance(pt1, pt2);
		pt1.dispose();
		pt2.dispose();

		return distance;
	}

	public function toStruct(ctx: SerialiseContext): Dynamic {
		final sf = this.__toStruct__(ctx, {});
		final entities: Array<String> = [];
		for (e in this.entities) {
			entities.push(e.identifier());
		}
		sf.entities = entities;
		return sf;
	}

	public function loadStruct(context: SerialiseContext, struct: Dynamic): Dynamic {
		final sf: TileSF = cast struct;
		for (id in sf.entities) {
			final entity = context.get(id);
			Assert.assert(entity != null);
			if (entity != null) {
				internalAddEntity(cast entity);
				final lc = LocationComponent.get(cast entity);
				lc.level = this.level;
				lc.level.entities.add(cast entity);
			}
		}
		return this;
	}
}
/**
	Thu 14:39:01 14 Nov 2024
	Imported from ren.core

	I did not add all the tile visibility stuff from the original ren.core yet.
	I think we can put that in when we make a game that need visibility.
	Then we can take the code in + the code from ETA.

	Light source is also not added to Tile
**/
