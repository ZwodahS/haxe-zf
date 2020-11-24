package zf;

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

class Direction {
    public var direction(get, never): DirectionType;
    public var cardinalDirection(default, null): CardinalDirectionType;
    public var coord(get, never): Point2i;

    public function new(cDirectionType: CardinalDirectionType = None) {
        this.cardinalDirection = cDirectionType;
    }

    public function get_direction(): DirectionType {
        switch (this.cardinalDirection) {
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

    public function get_coord(): Point2i {
        switch (this.cardinalDirection) {
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

    public static function fromDirection(type: DirectionType): Direction {
        switch (type) {
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
            default:
                return new Direction(None);
        }
    }

    public static function fromPoint2i(point: Point2i): Direction {
        /**
            This will bound all x and y between -1 and 1
            origin is top left, meaning (1, 1) will be South East
            TODO: might want to provide a different coordinate system if necessary
        **/
        var xDiff = MathUtils.clampI(point.x, -1, 1);

        var yDiff = MathUtils.clampI(point.y, -1, 1);
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

    public static function fromPointPerspective(coord1: Point2i, coord2: Point2i): Direction {
        return fromPoint2i([coord2.x - coord1.x, coord2.y - coord1.y]);
    }

    public function opposite(): Direction {
        switch (this.cardinalDirection) {
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

    public function toString(): String {
        return '${this.cardinalDirection}|${this.direction}';
    }
}
