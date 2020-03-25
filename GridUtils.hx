
package common;

import haxe.ds.Vector;
import haxe.ds.List;

class GridUtils {
    public static function getAround<T>
            (grid: Vector<Vector<T>>, coord: Point2i, width:Int = 1, includeSelf: Bool = true): Array<T> {
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
    public static function getPointsAround
            (coord: Point2i, width:Int = 1, bound: Recti = null, includeSelf: Bool = true): Array<Point2i> {
        var cellList: Array<Point2i> = new Array<Point2i>();
        for (x in -(width)...(width+1)) {
            for (y in -(width)...(width+1)) {
                if (x == 0 && y == 0 && !includeSelf) continue;
                var c = coord + [x, y];
                if (bound == null ||
                        (c.x >= bound.xMin && c.x <= bound.xMax && c.y >= bound.yMin && c.y <= bound.yMax)) {
                    cellList.push(c);
                }
            }
        }
        return cellList;
    }

    public static inline function translateMouseToWorld(mousePosition: Point2f, camera: h2d.Camera): Point2f {
        var pos = mousePosition - [ camera.x, camera.y ];
        pos.x = pos.x / camera.scaleX;
        pos.y = pos.y / camera.scaleY;
        return pos;
    }

    public static inline function translateMouseToWorldGrid
            (size: Int, screenCoord: Point2f, camera: h2d.Camera = null): Point2i {
        if (camera == null) {
            return [ Math.floor(screenCoord.x / size), Math.floor(screenCoord.y / size) ];
        }
        var pos = translateMouseToWorld(screenCoord, camera);
        return [ Math.floor(pos.x / size), Math.floor(pos.y / size) ];

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
}
