package common;

enum Direction {
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

class Utils {
    public static function directionToCoord(direction: Direction): Point2i {
        switch (direction) {
            case Left:
                return new Point2i(-1, 0);
            case UpLeft:
                return new Point2i(-1, -1);
            case Up:
                return new Point2i(0, -1);
            case UpRight:
                return new Point2i(1, -1);
            case Right:
                return new Point2i(1, 0);
            case DownRight:
                return new Point2i(1, 1);
            case Down:
                return new Point2i(0, 1);
            case DownLeft:
                return new Point2i(-1, 1);
            case None:
                return new Point2i(0, 0);
            default:
                return new Point2i();
        }
    }

    public static function coordToDirection(coord1: Point2i, coord2: Point2i): Direction {
        var xDiff = coord2.x - coord1.x;
        var yDiff = coord2.y - coord1.y;

        if (xDiff == 0) {
            if (yDiff == 0) {
                return Direction.None;
            } else if (yDiff == 1) {
                return Direction.Down;
            } else if (yDiff == -1) {
                return Direction.Up;
            }
        } else if (xDiff == 1) {
            if (yDiff == 0) {
                return Direction.Right;
            } else if (yDiff == 1) {
                return Direction.UpRight;
            } else if (yDiff == -1) {
                return Direction.DownRight;
            }
        } else if (xDiff == -1) {
            if (yDiff == 0) {
                return Direction.Left;
            } else if (yDiff == 1) {
                return Direction.UpLeft;
            } else if (yDiff == -1) {
                return Direction.UpLeft;
            }
        }

        return Direction.None;
    }

    public static function opposite(direction: Direction): Direction {
        switch (direction) {
            case Left:
                return Direction.Right;
            case UpLeft:
                return Direction.DownRight;
            case Up:
                return Direction.Down;
            case UpRight:
                return Direction.DownLeft;
            case Right:
                return Direction.Left;
            case DownRight:
                return Direction.UpLeft;
            case Down:
                return Direction.Up;
            case DownLeft:
                return Direction.UpRight;
            case None:
                return Direction.None;
            default:
                return Direction.None;
        }
        return Direction.None;
    }
}
