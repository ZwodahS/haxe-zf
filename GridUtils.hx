
package common;

import haxe.ds.Vector;
import haxe.ds.List;

class GridUtils {
    public static function getAround<T>(grid: Vector<Vector<T>>, coord: Point2i, width:Int = 1, includeSelf: Bool = true): Array<T> {
        var cellList: Array<T> = new Array<T>();
        for (x in -(width)...(width+1)) {
            for (y in -(width)...(width+1)) {
                if (x == 0 && y == 0 && !includeSelf) continue;
                var c = coord + [x, y];
                if (c.x >= 0 && c.x < grid.length && c.y >= 0 && c.y < grid[0].length) {
                    cellList.push(grid[c.x][c.y]);
                }
            }
        }
        return cellList;
    }
    public static function getPointsAround(coord: Point2i, width:Int = 1, bound: Recti, includeSelf: Bool = true): Array<Point2i> {
        var cellList: Array<Point2i> = new Array<Point2i>();
        for (x in -(width)...(width+1)) {
            for (y in -(width)...(width+1)) {
                if (x == 0 && y == 0 && !includeSelf) continue;
                var c = coord + [x, y];
                if (c.x >= bound.xMin && c.x <= bound.xMax && c.y >= bound.yMin && c.y <= bound.yMax) {
                    cellList.push(c);
                }
            }
        }
        return cellList;
    }
}
