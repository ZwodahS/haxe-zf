package tests.zf;

import zf.Direction;
import zf.tests.TestCase;

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
}
