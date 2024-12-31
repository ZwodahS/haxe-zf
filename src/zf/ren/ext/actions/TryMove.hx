package zf.ren.ext.actions;

/**
	A general purpose Action for trying to move in a specific direction.

	This provide multiple method that can be specialised to provide different type of movement logic.

	This should not be used directly. Instead extend it to add more functionality
**/
class TryMove extends Action {
	var direction: Direction = null;
	var world: World = null;
	var x: Null<Int> = null;
	var y: Null<Int> = null;
	public var canBump: Bool = true;

	override public function perform(onFinish: ActionResult->Void): Bool {
		Assert.assert(this.world != null && this.entity != null);
		Assert.assert(this.direction != null || (this.x != null && this.y != null));
		// make sure the entity is on a level before attempting the move.
		final lc = LocationComponent.get(this.entity);
		if (lc == null || lc.level == null) return false;

		final level = lc.level;
		// make sure that the target position has a tile
		final targetPosition: Point2i = [lc.x, lc.y];

		if (this.direction == null) {
			targetPosition.set(this.x, this.y);
		} else {
			targetPosition += direction;
		}

		final toTile = level.tiles.get(targetPosition.x, targetPosition.y);
		targetPosition.dispose();

		if (toTile == null) return false;

		if (canBump == true) {
			// find an entity that can be 'bumped'
			final bumpable = toTile.entities.findEntity(this.isEntityBumpable);

			// if the bumpable is handled, then we are done, else we continue to try to move to the tile.
			if (bumpable != null) {
				if (onEntityBump(toTile, bumpable, onFinish) == true) return true;
			}
		}

		final fromTile = lc.tile;

		if (!canMoveEntity(fromTile, toTile)) return false;

		moveEntity(entity, toTile, onFinish);

		return true;
	}

	function moveEntity(entity: Entity, tile: Tile, onFinish: ActionResult->Void) {
		this.animateMove(entity, tile.x, tile.y, () -> {
			this.world.moveEntity(entity, tile.x, tile.y);
			onEntityMoved();
			onFinish(getActionResult());
		});
	}

	override public function dispose() {
		super.dispose();
		this.direction = null;
		this.world = null;
		this.x = null;
		this.y = null;
		this.canBump = true;
	}

	function animateMove(entity: Entity, x: Int, y: Int, onFinish: Void->Void) {
		onFinish();
	}

	function getActionResult(): ActionResult {
		return ActionResult.alloc();
	}

	/**
		check if an entity can move to this position.

		@param position the position to move to

		@return null if unable to move, or the movement cost if the entity is able to move.
	**/
	function canMoveEntity(fromTile: Tile, toTile: Tile): Bool {
		return true;
	}

	function isEntityBumpable(target: Entity): Bool {
		return false;
	}

	function onEntityBump(tile: Tile, target: Entity, onFinish: ActionResult->Void): Bool {
		return false;
	}

	function onEntityMoved() {}
}
