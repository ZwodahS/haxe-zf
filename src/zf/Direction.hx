package zf;

using zf.RandExtensions;

enum DirectionType {
	Left;
	UpLeft;
	Up;
	UpRight;
	Right;
	DownRight;
	Down;
	DownLeft;
	None;
}

enum CardinalDirectionType {
	West;
	NorthWest;
	North;
	NorthEast;
	East;
	SouthEast;
	South;
	SouthWest;
	None;
}

abstract Direction(CardinalDirectionType) from CardinalDirectionType to CardinalDirectionType {
	public function new(cDirectionType: CardinalDirectionType = None) {
		this = cDirectionType;
	}

	@:to public function toDirection(): DirectionType {
		switch (this) {
			case West:
				return Left;
			case NorthWest:
				return UpLeft;
			case North:
				return Up;
			case NorthEast:
				return UpRight;
			case East:
				return Right;
			case SouthEast:
				return DownRight;
			case South:
				return Down;
			case SouthWest:
				return DownLeft;
			case None:
				return None;
		}
		return None;
	}

	@:from public static function fromDirection(d: DirectionType): Direction {
		switch (d) {
			case Left:
				return new Direction(West);
			case UpLeft:
				return new Direction(NorthWest);
			case Up:
				return new Direction(North);
			case UpRight:
				return new Direction(NorthEast);
			case Right:
				return new Direction(East);
			case DownRight:
				return new Direction(SouthEast);
			case Down:
				return new Direction(South);
			case DownLeft:
				return new Direction(SouthWest);
			case None:
				return new Direction(None);
		}
		return new Direction(None);
	}

	@:to public function toPoint2i(): Point2i {
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
			case None:
				return [0, 0];
		}
		return [0, 0];
	}

	public static function fromXY(x: Int, y: Int): Direction {
		/**
			This will bound all x and y between -1 and 1
			origin is top left, meaning (1, 1) will be South East
			TODO: might want to provide a different coordinate system if necessary
		**/
		var xDiff = MathUtils.clampI(x, -1, 1);

		var yDiff = MathUtils.clampI(y, -1, 1);
		if (xDiff == 0) {
			if (yDiff == 0) {
				return new Direction(None);
			} else if (yDiff == 1) {
				return new Direction(South);
			} else if (yDiff == -1) {
				return new Direction(North);
			}
		} else if (xDiff == 1) {
			if (yDiff == 0) {
				return new Direction(East);
			} else if (yDiff == 1) {
				return new Direction(SouthEast);
			} else if (yDiff == -1) {
				return new Direction(NorthEast);
			}
		} else if (xDiff == -1) {
			if (yDiff == 0) {
				return new Direction(West);
			} else if (yDiff == 1) {
				return new Direction(SouthWest);
			} else if (yDiff == -1) {
				return new Direction(NorthWest);
			}
		}
		return new Direction(None);
	}

	@:from public static function fromPoint2i(point: Point2i): Direction {
		return fromXY(point.x, point.y);
	}

	public static function fromPointPerspective(coord1: Point2i, coord2: Point2i): Direction {
		return fromPoint2i([coord2.x - coord1.x, coord2.y - coord1.y]);
	}

	public var opposite(get, never): Direction;

	public function get_opposite(): Direction {
		switch (this) {
			case West:
				return new Direction(East);
			case NorthWest:
				return new Direction(SouthEast);
			case North:
				return new Direction(South);
			case NorthEast:
				return new Direction(SouthWest);
			case East:
				return new Direction(West);
			case SouthEast:
				return new Direction(NorthWest);
			case South:
				return new Direction(North);
			case SouthWest:
				return new Direction(NorthEast);
			case None:
				return new Direction(None);
		}
		return new Direction(None);
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
				return [new Direction(SouthWest), new Direction(NorthWest)];
			case NorthWest:
				return [new Direction(West), new Direction(North)];
			case North:
				return [new Direction(NorthWest), new Direction(NorthEast)];
			case NorthEast:
				return [new Direction(North), new Direction(East)];
			case East:
				return [new Direction(NorthEast), new Direction(SouthEast)];
			case SouthEast:
				return [new Direction(East), new Direction(South)];
			case South:
				return [new Direction(SouthEast), new Direction(SouthWest)];
			case SouthWest:
				return [new Direction(South), new Direction(West)];
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
				return [new Direction(North), new Direction(South)];
			case East:
				return [new Direction(North), new Direction(South)];
			case NorthWest:
				return [new Direction(NorthEast), new Direction(SouthWest)];
			case SouthEast:
				return [new Direction(NorthEast), new Direction(SouthWest)];
			case North:
				return [new Direction(West), new Direction(East)];
			case South:
				return [new Direction(West), new Direction(East)];
			case SouthWest:
				return [new Direction(NorthWest), new Direction(SouthWest)];
			case NorthEast:
				return [new Direction(NorthWest), new Direction(SouthWest)];
			case None:
				return [];
		}
		return [];
	}

	public var cardinalShortString(get, never): String;

	public function get_cardinalShortString(): String {
		switch (this: CardinalDirectionType) {
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

	@:to public function toString(): String {
		return '${toDirection()}';
	}

	@:from public static function fromString(s: String): Direction {
		switch (s) {
			case "West":
				return Left;
			case "Left":
				return Left;
			case "NorthWest":
				return UpLeft;
			case "Upleft":
				return UpLeft;
			case "North":
				return Up;
			case "Up":
				return Up;
			case "NorthEast":
				return UpRight;
			case "UpRight":
				return UpRight;
			case "East":
				return Right;
			case "Right":
				return Right;
			case "SouthEast":
				return DownRight;
			case "DownRight":
				return DownRight;
			case "South":
				return Down;
			case "Down":
				return Down;
			case "SouthWest":
				return DownLeft;
			case "DownLeft":
				return DownLeft;
			case "None":
				return None;
		}
		return None;
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

	public function rotateCW(i: Int): Direction {
		var d: Direction = this;
		for (_ in 0...i) d = d.clockwise;
		return d;
	}

	public function rotateCCW(i: Int): Direction {
		var d: Direction = this;
		for (_ in 0...i) d = d.cclockwise;
		return d;
	}

	public var int(get, never): Int;

	public function get_int(): Int {
		var d: Direction = this;
		switch (d) {
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

	public static function allFourDirections(): Array<Direction> {
		return [North, East, South, West];
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

	public static function allEightDirections(): Array<Direction> {
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
}
