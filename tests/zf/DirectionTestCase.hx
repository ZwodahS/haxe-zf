package tests.zf;

import zf.Assert;
import zf.Point2i;
import zf.Direction;

class DirectionTestCase extends TestCase {
	public static final Name = "DirectionTestCase";

	override public function get_name(): String {
		return Name;
	}

	function test_equality() {
		Assert.assertEqual(North, Up);

		Assert.assertEqual(NorthEast, UpRight);
		Assert.assertEqual(East, Right);
		Assert.assertEqual(SouthEast, DownRight);
		Assert.assertEqual(South, Down);
		Assert.assertEqual(SouthWest, DownLeft);
		Assert.assertEqual(West, Left);
		Assert.assertEqual(NorthWest, UpLeft);
	}

	function test_rotate() {
		var d: Direction = East;
		Assert.assertEqual(d.rotateCW(2), South);
	}

	function test_point_and_direction() {
		final p: Point2i = new Point2i(0, 0);
		final d: Direction = East;
		final d2: Point2i = d;
		Assert.assertEqual(d2.x, 1);
		Assert.assertEqual(d2.y, 0);
		d2.x = 0;
		Assert.assertEqual(d, East);

		final p2 = p.clone();
		p2.move(d);
		Assert.assertEqual(p2.x, 1);
		Assert.assertEqual(p2.y, 0);
	}

	override public function run() {
		test_equality();
		test_rotate();
		test_point_and_direction();
	}
}
