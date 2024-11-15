package zf;

/**
	@stage:stable
**/
class Line2i {
	public static function getLineXYSymmetry(startX: Int, startY: Int, endX: Int, endY: Int,
			reversed: Bool = false): List<Point2i> {
		// http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
		// modified from python version
		var x1 = startX, y1 = startY;
		var x2 = endX, y2 = endY;
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
		var points = new List<Point2i>();
		var insertFunc = reversed ? points.push : points.add;
		if (x1 < x2) {
			var dx = x2 - x1;
			var dy = y2 - y1;

			var errorValue: Int = Std.int(dx / 2.0);
			var yStep = -1;
			if (y1 < y2) {
				yStep = 1;
			}

			var y = y1, x = x1;
			while (x < x2 + 1) {
				var point: Point2i = null;
				if (isSteep) {
					point = Point2i.alloc(y, x);
				} else {
					point = Point2i.alloc(x, y);
				}
				insertFunc(point);
				errorValue -= hxd.Math.iabs(dy);
				if (errorValue < 0) {
					y += yStep;
					errorValue += dx;
				}

				x++;
			}
		} else {
			var dx = x1 - x2;
			var dy = y1 - y2;

			var errorValue: Int = Std.int(dx / 2.0);
			var yStep = -1;
			if (y1 < y2) {
				yStep = 1;
			}

			var y = y1, x = x1;
			while (x > x2 - 1) {
				var point: Point2i = null;
				if (isSteep) {
					point = Point2i.alloc(y, x);
				} else {
					point = Point2i.alloc(x, y);
				}
				insertFunc(point);
				errorValue -= hxd.Math.iabs(dy);
				if (errorValue < 0) {
					y += yStep;
					errorValue += dx;
				}
				x--;
			}
		}
		return points;
	}

	public static function getLineDirectionSymmetry(startX: Int, startY: Int, endX: Int, endY: Int): List<Point2i> {
		// http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
		// modified from python version
		var x1 = startY, y1 = startY;
		var x2 = endX, y2 = endY;
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
				point = Point2i.alloc(y, x);
			} else {
				point = Point2i.alloc(x, y);
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

	public static function getLine(startX: Int, startY: Int, endX: Int, endY: Int,
			xySymmetry: Bool = false): List<Point2i> {
		if (xySymmetry) return getLineXYSymmetry(startX, startY, endX, endY);
		return getLineDirectionSymmetry(startX, startY, endX, endY);
	}

	public static function getLinesBothDirection(startX: Int, startY: Int, endX: Int, endY: Int): Array<List<Point2i>> {
		return [
			getLineXYSymmetry(startX, startY, endX, endY),
			getLineXYSymmetry(endX, endY, startX, startY, true),
		];
	}
}
