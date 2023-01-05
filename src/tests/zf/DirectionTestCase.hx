package tests.zf;

import zf.Assert;
import zf.Point2i;
import zf.Direction;
import zf.deprecated.tests.TestCase;

class DirectionTestCase extends TestCase {
	function test_equality() {
		/**
			Wed 16:13:01 18 Aug 2021
			this might seems stupid to test, since they are the same string value
		**/
		assertEqual(North, Up);

		assertEqual(NorthEast, UpRight);
		assertEqual(East, Right);
		assertEqual(SouthEast, DownRight);
		assertEqual(South, Down);
		assertEqual(SouthWest, DownLeft);
		assertEqual(West, Left);
		assertEqual(NorthWest, UpLeft);
	}

	function test_rotate() {
		var d: Direction = East;
		assertEqual(d.rotateCW(2), South);
	}

	function test_point_and_direction() {
		final p: Point2i = new Point2i(0, 0);
		final d: Direction = East;
		final d2: Point2i = d;
		Assert.assertEqual(d2.x, 1);
		Assert.assertEqual(d2.y, 0);
		d2.x = 0;
		Assert.assertEqual(d, East);

		final p2 = p + d;
		Assert.assertEqual(p2.x, 1);
		Assert.assertEqual(p2.y, 0);
	}
}
