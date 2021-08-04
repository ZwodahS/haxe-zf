package zf;

import haxe.ds.Vector;
import haxe.ds.List;

/**
	Provide various functionalities related to grid.

	This is mostly deprecated and many of the functionality is moved to more appropriate places.
**/
class GridUtils {
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
