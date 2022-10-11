package zf;

class Line2i {
	public static function getLineXYSymmetry(start: Point2i, end: Point2i, reversed: Bool = false): List<Point2i> {
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
				x--;
			}
		}
		return points;
	}

	public static function getLineDirectionSymmetry(start: Point2i, end: Point2i): List<Point2i> {
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

	public static function getLine(start: Point2i, end: Point2i, xySymmetry: Bool = false): List<Point2i> {
		if (xySymmetry) return getLineXYSymmetry(start, end);
		return getLineDirectionSymmetry(start, end);
	}

	public static function getLinesBothDirection(start: Point2i, end: Point2i): Array<List<Point2i>> {
		return [getLineXYSymmetry(start, end), getLineXYSymmetry(end, start, true),];
	}
}
