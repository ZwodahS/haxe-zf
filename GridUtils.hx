package common;

import haxe.ds.Vector;
import haxe.ds.List;

class GridUtils {
    public static function getAround<T>(grid: Vector<Vector<T>>, coord: Point2i, width: Int = 1,
            includeSelf: Bool = true): Array<T> {
        var cellList: Array<T> = new Array<T>();
        for (x in -(width)...(width + 1)) {
            for (y in -(width)...(width + 1)) {
                if (x == 0 && y == 0 && !includeSelf) continue;
                var c = coord + [x, y];
                if (c.x >= 0 && c.x < grid.length && c.y >= 0 && c.y < grid[0].length) {
                    cellList.push(grid[c.x][c.y]);
                }
            }
        }
        return cellList;
    }

    public static function getPointsAround(coord: Point2i, width: Int = 1, bound: Recti = null,
            includeSelf: Bool = true): Array<Point2i> {
        var cellList: Array<Point2i> = new Array<Point2i>();
        for (x in -(width)...(width + 1)) {
            for (y in -(width)...(width + 1)) {
                if (x == 0 && y == 0 && !includeSelf) continue;
                var c = coord + [x, y];
                if (bound == null
                    || (c.x >= bound.xMin && c.x <= bound.xMax && c.y >= bound.yMin && c.y <= bound.yMax)) {
                    cellList.push(c);
                }
            }
        }
        return cellList;
    }

    public static inline function translateMouseToWorld(mousePosition: Point2f,
            camera: h2d.Camera): Point2f {
        var pos = mousePosition - [camera.x, camera.y];
        pos.x = pos.x / camera.scaleX;
        pos.y = pos.y / camera.scaleY;
        return pos;
    }

    public static inline function translateMouseToWorldGrid(size: Int, screenCoord: Point2f,
            camera: h2d.Camera = null): Point2i {
        if (camera == null) {
            return [Math.floor(screenCoord.x / size), Math.floor(screenCoord.y / size)];
        }
        var pos = translateMouseToWorld(screenCoord, camera);
        return [Math.floor(pos.x / size), Math.floor(pos.y / size)];
    }

    public static inline function inGrid(pos: Point2i, size: Point2i): Bool {
        return pos.x >= 0 && pos.x < size.x && pos.y >= 0 && pos.y < size.y;
    }

    public static inline function inGridArray<T>(pos: Point2i, grid: Vector<Vector<T>>): Bool {
        return pos.x >= 0 && pos.x < grid.length && pos.y >= 0 && pos.y < grid[0].length;
    }

    public static inline function getItemIn2DArray<T>(pos: Point2i, grid: Vector<Vector<T>>): T {
        return (inGridArray(pos, grid)) ? grid[pos.x][pos.y] : null;
    }

    public static function getLine(start: Point2i, end: Point2i): List<Point2i> {
        // http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
        // modified from python version
        var x1 = start.x, y1 = start.y;
        var x2 = end.x, y2 = end.y;
        var isSteep = hxd.Math.iabs(y2 - y1) > hxd.Math.iabs(x2 - x1);

        var tmp: Int = 0;
        if (isSteep) {
            tmp = x1;
            x1 = y1;
            y1 = tmp;
            tmp = x2;
            x2 = y2;
            y2 = tmp;
        }

        var reversed = false;
        if (x1 > x2) {
            tmp = x1;
            x1 = x2;
            x2 = tmp;
            tmp = y1;
            y1 = y2;
            y2 = tmp;
            reversed = true;
        }

        var dx = x2 - x1;
        var dy = y2 - y1;

        var errorValue: Int = Std.int(dx / 2.0);
        var yStep = -1;
        if (y1 < y2) {
            yStep = 1;
        }

        var points = new List<Point2i>();
        var insertFunc = reversed ? points.push : points.add;
        var y = y1, x = x1;
        while (x < x2 + 1) {
            var point: Point2i = null;
            if (isSteep) {
                point = new Point2i(y, x);
            } else {
                point = new Point2i(x, y);
            }
            insertFunc(point);
            errorValue -= hxd.Math.iabs(dy);
            if (errorValue < 0) {
                y += yStep;
                errorValue += dx;
            }

            x++;
        }
        return points;
    }

    public static function getCircle(center: Point2i, radius: Int): List<Point2i> {
        // https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
        var x0 = center.x, y0 = center.y;
        var x = radius;
        var y = 0;
        var err = 0;

        var pointsSet = new Map<String, Point2i>();

        while (x >= y) {
            pointsSet['${x0 + x}_${y0 + y}'] = new Point2i(x0 + x, y0 + y);
            pointsSet['${x0 + y}_${y0 + x}'] = new Point2i(x0 + y, y0 + x);
            pointsSet['${x0 - y}_${y0 + x}'] = new Point2i(x0 - y, y0 + x);
            pointsSet['${x0 - x}_${y0 + y}'] = new Point2i(x0 - x, y0 + y);
            pointsSet['${x0 - x}_${y0 - y}'] = new Point2i(x0 - x, y0 - y);
            pointsSet['${x0 - y}_${y0 - x}'] = new Point2i(x0 - y, y0 - x);
            pointsSet['${x0 + y}_${y0 - x}'] = new Point2i(x0 + y, y0 - x);
            pointsSet['${x0 + x}_${y0 - y}'] = new Point2i(x0 + x, y0 - y);

            if (err <= 0) {
                y++;
                err += 2 * y + 1;
            }
            if (err > 0) {
                x--;
                err -= 2 * x + 1;
            }
        }

        var points = new List<Point2i>();
        for (point in pointsSet) {
            points.push(point);
        }
        return points;
    }
}
