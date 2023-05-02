package zf;

import haxe.ds.ArraySort;

/**
	@stage:stable

	Direction provide the implementation to handle the 8 direction on a 2D area.

	Notes on using Direction:
	1. When using direction, it should be used like a primitive.
**/
enum abstract Direction(String) from String to String {
	public var North = "North";
	public var Up = "North";
	public var NorthEast = "NorthEast";
	public var UpRight = "NorthEast";
	public var East = "East";
	public var Right = "East";
	public var SouthEast = "SouthEast";
	public var DownRight = "SouthEast";
	public var South = "South";
	public var Down = "South";
	public var SouthWest = "SouthWest";
	public var DownLeft = "SouthWest";
	public var West = "West";
	public var Left = "West";
	public var NorthWest = "NorthWest";
	public var UpLeft = "NorthWest";
	public var None = "None";
	public var point(get, never): Point2i;

	/**
		Convert a direction to a point2i.
		The value of each axis will be between -1, 1
	**/
	@:to public function get_point(): Point2i {
		switch (this) {
			case West:
				return [-1, 0];
			case NorthWest:
				return [-1, -1];
			case North:
				return [0, -1];
			case NorthEast:
				return [1, -1];
			case East:
				return [1, 0];
			case SouthEast:
				return [1, 1];
			case South:
				return [0, 1];
			case SouthWest:
				return [-1, 1];
			default:
				return [0, 0];
		}
		return [0, 0];
	}

	public var x(get, never): Int;

	public function get_x(): Int {
		return switch (this) {
			case West:
				return -1;
			case NorthWest:
				return -1;
			case North:
				return 0;
			case NorthEast:
				return 1;
			case East:
				return 1;
			case SouthEast:
				return 1;
			case South:
				return 0;
			case SouthWest:
				return -1;
			default:
				return 0;
		}
	}

	public var y(get, never): Int;

	public function get_y(): Int {
		return switch (this) {
			case West:
				return 0;
			case NorthWest:
				return -1;
			case North:
				return -1;
			case NorthEast:
				return -1;
			case East:
				return 0;
			case SouthEast:
				return 1;
			case South:
				return 1;
			case SouthWest:
				return 1;
			default:
				return 0;
		}
	}

	public function toPoint2i(): Point2i {
		return get_point();
	}

	/**
		Convert x, y to Direction.
		This is present so that we don't have to create a Point2i object just to convert to Direction

		@param x the x value
		@param y the y value
		@return the converted direction

		values will be clamped between -1 and 1 inclusive.
	**/
	public static function fromXY(x: Int, y: Int): Direction {
		// clamp the 2 values
		var xDiff = x.clamp(-1, 1);
		var yDiff = y.clamp(-1, 1);

		if (xDiff == 0) {
			if (yDiff == 0) {
				return None;
			} else if (yDiff == 1) {
				return South;
			} else if (yDiff == -1) {
				return North;
			}
		} else if (xDiff == 1) {
			if (yDiff == 0) {
				return East;
			} else if (yDiff == 1) {
				return SouthEast;
			} else if (yDiff == -1) {
				return NorthEast;
			}
		} else if (xDiff == -1) {
			if (yDiff == 0) {
				return West;
			} else if (yDiff == 1) {
				return SouthWest;
			} else if (yDiff == -1) {
				return NorthWest;
			}
		}
		return None;
	}

	/**
		Convert a point2i to a direction
	**/
	@:from public static function fromPoint2i(point: Point2i): Direction {
		return fromXY(point.x, point.y);
	}

	/**
		Get the direction of coord2 from coord1
		This is the same as `var d: Direction = coord2 - coord1

		@param coord1 the point of reference
		@param coord2 the target point
		@return the converted direction
	**/
	public static function fromPointPerspective(coord1: Point2i, coord2: Point2i): Direction {
		return fromPoint2i([coord2.x - coord1.x, coord2.y - coord1.y]);
	}

	/**
		get the opposite direction
	**/
	public var opposite(get, never): Direction;

	public function get_opposite(): Direction {
		switch (this) {
			case West:
				return East;
			case NorthWest:
				return SouthEast;
			case North:
				return South;
			case NorthEast:
				return SouthWest;
			case East:
				return West;
			case SouthEast:
				return NorthWest;
			case South:
				return North;
			case SouthWest:
				return NorthEast;
			case None:
				return None;
		}
		return None;
	}

	/**
		Split a diagonal direction into the four direction components.
		If Left Right Up Down is splitted, it will return an array of itself
	**/
	public function split(): Array<Direction> {
		switch (this) {
			case West:
				return [West];
			case NorthWest:
				return [North, West];
			case North:
				return [North];
			case NorthEast:
				return [North, East];
			case East:
				return [East];
			case SouthEast:
				return [South, East];
			case South:
				return [South];
			case SouthWest:
				return [South, West];
			case None:
				return [None];
		}
		return [None];
	}

	/**
		Returns an "adjacent" direction.

		Imagine the direction is mapped into the following.

		NW   N   NE
		W  None   E
		SW   S   SE

		Excluding none it will return the adjacent tiles.
		if none is pass, an empty list is passed
	**/
	public var adjacent(get, never): Array<Direction>;

	public function get_adjacent(): Array<Direction> {
		switch (this) {
			case West:
				return [SouthWest, NorthWest];
			case NorthWest:
				return [West, North];
			case North:
				return [NorthWest, NorthEast];
			case NorthEast:
				return [North, East];
			case East:
				return [NorthEast, SouthEast];
			case SouthEast:
				return [East, South];
			case South:
				return [SouthEast, SouthWest];
			case SouthWest:
				return [South, West];
			case None:
				return [];
		}
		return [];
	}

	/**
		Return the points on the opposite axis to this direction.

		NW   N   NE
		W  None   E
		SW   S   SE

		In this case,
		- N and S will return W and E
		- NW and SE will return SW and NE respectively
	**/
	public var oppositeAxis(get, never): Array<Direction>;

	public function get_oppositeAxis(): Array<Direction> {
		switch (this) {
			case West:
				return [North, South];
			case East:
				return [North, South];
			case NorthWest:
				return [NorthEast, SouthWest];
			case SouthEast:
				return [NorthEast, SouthWest];
			case North:
				return [West, East];
			case South:
				return [West, East];
			case SouthWest:
				return [NorthWest, SouthWest];
			case NorthEast:
				return [NorthWest, SouthWest];
			case None:
				return [];
		}
		return [];
	}

	public var cardinalShortString(get, never): String;

	public function get_cardinalShortString(): String {
		switch (this) {
			case West:
				return 'W';
			case NorthWest:
				return 'NW';
			case North:
				return 'N';
			case NorthEast:
				return 'NE';
			case East:
				return 'E';
			case SouthEast:
				return 'SE';
			case South:
				return 'S';
			case SouthWest:
				return 'SW';
			case None:
				return '';
		}
		return '';
	}

	public var clockwise(get, never): Direction;

	public function get_clockwise(): Direction {
		switch (this) {
			case West:
				return NorthWest;
			case NorthWest:
				return North;
			case North:
				return NorthEast;
			case NorthEast:
				return East;
			case East:
				return SouthEast;
			case SouthEast:
				return South;
			case South:
				return SouthWest;
			case SouthWest:
				return West;
			case None:
				return None;
		}
		return None;
	}

	public var cclockwise(get, never): Direction;

	public function get_cclockwise(): Direction {
		switch (this) {
			case West:
				return SouthWest;
			case NorthWest:
				return West;
			case North:
				return NorthWest;
			case NorthEast:
				return North;
			case East:
				return NorthEast;
			case SouthEast:
				return East;
			case South:
				return SouthEast;
			case SouthWest:
				return South;
			case None:
				return None;
		}
		return None;
	}

	/**
		rotate this direction n times clockwise and return the new direction.
		this does not mutate the direction

		@param n the number of times to rotate
		@return the direction
	**/
	public function rotateCW(n: Int): Direction {
		var d: Direction = this;
		for (_ in 0...n) d = d.clockwise;
		return d;
	}

	/**
		rotate this direction n times counter-clockwise and return the new direction.
		this does not mutate the direction

		@param n the number of times to rotate
		@return the direction
	**/
	public function rotateCCW(n: Int): Direction {
		var d: Direction = this;
		for (_ in 0...n) d = d.cclockwise;
		return d;
	}

	public var int(get, never): Int;

	public function get_int(): Int {
		switch (this) {
			case North:
				return 0;
			case NorthEast:
				return 1;
			case East:
				return 2;
			case SouthEast:
				return 3;
			case South:
				return 4;
			case SouthWest:
				return 5;
			case West:
				return 6;
			case NorthWest:
				return 7;
			default:
				return 8;
		}
	}

	/**
		Get all 4 directions. if r is provided, then the array will be shuffled.
	**/
	inline public static function allFourDirections(r: hxd.Rand = null): Array<Direction> {
		var d = [North, East, South, West];
		if (r != null) d.shuffle(r);
		return d;
	}

	public static function randomFourDirection(r: hxd.Rand): Direction {
		switch (r.randomInt(4)) {
			case 0:
				return North;
			case 1:
				return East;
			case 2:
				return South;
			case 3:
				return West;
			default:
				return North;
		}
	}

	inline public static function allEightDirections(): Array<Direction> {
		return [North, NorthEast, East, SouthEast, South, SouthWest, West, NorthWest];
	}

	public static function randomEightDirection(r: hxd.Rand): Direction {
		switch (r.randomInt(8)) {
			case 0:
				return North;
			case 1:
				return East;
			case 2:
				return South;
			case 3:
				return West;
			case 4:
				return NorthEast;
			case 5:
				return NorthWest;
			case 6:
				return SouthEast;
			case 7:
				return SouthWest;
			default:
				return North;
		}
	}

	// takes in a list of directions and sort them based on a distanceFunc
	// if directions is not provided, all directions will be used.
	public static function getSortedDirections(center: Point2i, target: Point2i, distanceFunc: (Int, Int) -> Int,
			directions: Array<Direction> = null, reversed = false): Array<Direction> {
		if (directions == null) directions = allEightDirections();

		var directionsWithDistance: Array<{c: Int, direction: Direction}> = [];
		for (d in directions) {
			var pt = d.point;
			// @formatter:off
			var distance = distanceFunc(
				hxd.Math.iabs(pt.x + center.x - target.x), hxd.Math.iabs(pt.y + center.y - target.y)
			);
			directionsWithDistance.push({c: distance, direction: d});
		}

		if (reversed) {
			ArraySort.sort(directionsWithDistance, function(x1, x2) { return x2.c - x1.c; });
		} else {
			ArraySort.sort(directionsWithDistance, function(x1, x2) { return x1.c - x2.c; });
		}
		return [ for (x in directionsWithDistance) x.direction ];
	}
}
/**
	Wed 15:34:55 18 Aug 2021
	Refactored Direction to enum abstract.
	We will store them as String as Int does not allow for null value and we need it.

	Still testing how I want direction to be implemented.
	There is no need to know how it is implemented when using it so it should be fine.

	For now we will implement it using String, previously it was implemented using 2 type of enums which was
	quite hard handle switch statement.

	There might also be some advantage to handle it via bitmask instead to allow for North | East to create NorthEast.
	However, that creates confusions in cases like North | South.
	Therefore, it is better not to have to think about it.
**/
