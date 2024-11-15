package zf.ren.core;

/**
	iterate tiles from a center point, slowly outwards, until it covers all the tiles in the level.
**/
class TilesIterator {
	var level: Level;
	var centerX: Int;
	var centerY: Int;
	var r: hxd.Rand;

	var currentDistance: Int = 0;
	var current: Array<Tile>;
	var finished: Bool = false;
	var minDistance: Int = 0;
	var maxDistance: Int = -1;
	var itNext: Point2i = null;

	public function new(level: Level, x: Int, y: Int, r: hxd.Rand, minDistance: Int = 0, maxDistance: Int = -1) {
		this.level = level;
		this.centerX = x;
		this.centerY = y;
		this.r = r;
		this.current = [];
		this.currentDistance = minDistance;
		this.maxDistance = maxDistance;
		this.itNext = [];
	}

	function initNext() {
		final distance = this.currentDistance++;
		if (maxDistance != -1 && distance > this.maxDistance) {
			finished = true;
			return;
		}

		if (distance == 0) {
			var tile = this.level.getTile(centerX, centerY);
			if (tile != null) current.push(tile);
		} else {
			for (x in (centerX - distance)...(centerX + distance + 1)) {
				// push centerY - distance and centerY + distance
				var tile = this.level.getTile(x, centerY - distance);
				if (tile != null) current.push(tile);

				tile = this.level.getTile(x, centerY + distance);
				if (tile != null) current.push(tile);
			}

			for (y in (centerY - distance + 1)...(centerY + distance)) {
				// push centerX - distance + 1 and centerX + distance
				// however, don't repeat y = 0 because we already did it in the previous loop
				// similar, don't add y = centerY + distance - 1
				var tile = this.level.getTile(centerX - distance, y);
				if (tile != null) current.push(tile);

				tile = this.level.getTile(centerX + distance, y);
				if (tile != null) current.push(tile);
			}
		}
		// if there is no tiles after the above checks, we are done
		if (this.current.length == 0) finished = true;
	}

	public function hasNext(): Bool {
		if (this.current.length == 0 && !this.finished) initNext();
		return !this.finished;
	}

	public function next(): Tile {
		return this.r.randomPopItem(this.current);
	}
}
