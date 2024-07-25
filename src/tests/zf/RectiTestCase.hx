package tests.zf;

import zf.Assert;
import zf.Point2i;
import zf.Recti;

class RectiTestCase extends TestCase {
	public static final Name = "RectiTestCase";

	override public function get_name(): String {
		return Name;
	}

	function test_recti_boundRect() {
		var rect1 = new Recti(4, 5, 8, 9);
		var rect2 = new Recti(5, 5, 6, 6);

		var bound = rect1.boundRect(rect2);
		Assert.assert(bound == rect2);

		var rect3 = new Recti(2, 2, 6, 6);
		var bound = rect1.boundRect(rect3);
		Assert.assert(bound == new Recti(4, 5, 6, 6));

		var rect4 = new Recti(2, 2, 3, 3);
		var bound = rect1.boundRect(rect4);
		Assert.assert(bound == new Recti(4, 5, 4, 5));

		var rect5 = new Recti(9, 9, 12, 12);
		var bound = rect1.boundRect(rect5);
		Assert.assert(bound == new Recti(8, 9, 8, 9));
	}

	function test_recti_points() {
		var rect = new Recti(3, 4, 6, 7);
		var points = rect.points;
		var outcome: Array<Point2i> = [
			[3, 4], [4, 4], [5, 4], [6, 4],
			[3, 5], [4, 5], [5, 5], [6, 5],
			[3, 6], [4, 6], [5, 6], [6, 6],
			[3, 7], [4, 7], [5, 7], [6, 7]
		];
		Assert.assertEqual(outcome.length, points.length);
		for (ind in 0...outcome.length) {
			Assert.assert(points[ind] == outcome[ind]);
		}
	}

	function test_recti_split_horizontal() {
		var rect = new Recti(0, 0, 9, 9);
		var rs = rect.splitHorizontal(5);
		Assert.assert(rs[0] == new Recti(0, 0, 4, 9));
		Assert.assert(rs[1] == new Recti(5, 0, 9, 9));

		var rs = rect.splitHorizontal(9);
		Assert.assert(rs[0] == new Recti(0, 0, 8, 9));
		Assert.assert(rs[1] == new Recti(9, 0, 9, 9));

		var rs = rect.splitHorizontal(0);
		Assert.assert(rs[0] == null);
		Assert.assert(rs[1] == new Recti(0, 0, 9, 9));

		var rs = rect.splitHorizontal(10);
		Assert.assert(rs[0] == new Recti(0, 0, 9, 9));
		Assert.assert(rs[1] == null);
	}

	function test_recti_split_vertical() {
		var rect = new Recti(0, 0, 9, 9);
		var rs = rect.splitVertical(5);
		Assert.assert(rs[0] == new Recti(0, 0, 9, 4));
		Assert.assert(rs[1] == new Recti(0, 5, 9, 9));

		var rs = rect.splitVertical(9);
		Assert.assert(rs[0] == new Recti(0, 0, 9, 8));
		Assert.assert(rs[1] == new Recti(0, 9, 9, 9));

		var rs = rect.splitVertical(0);
		Assert.assert(rs[0] == null);
		Assert.assert(rs[1] == new Recti(0, 0, 9, 9));

		var rs = rect.splitVertical(10);
		Assert.assert(rs[0] == new Recti(0, 0, 9, 9));
		Assert.assert(rs[1] == null);
	}

	function test_recti_setters() {
		var rect = new Recti(0, 0, 2, 3); // this is a 3 by 4 rect

		rect.left = 3;
		Assert.assert(rect == [3, 0, 5, 3]);
		Assert.assertEqual(rect.width, 3);
		Assert.assertEqual(rect.height, 4);

		rect.top = 4;
		Assert.assert(rect == [3, 4, 5, 7]);
		Assert.assertEqual(rect.width, 3);
		Assert.assertEqual(rect.height, 4);

		rect.right = 9;
		Assert.assert(rect == [7, 4, 9, 7]);
		Assert.assertEqual(rect.width, 3);
		Assert.assertEqual(rect.height, 4);

		rect.bottom = 10;
		Assert.assert(rect == [7, 7, 9, 10]);
		Assert.assertEqual(rect.width, 3);
		Assert.assertEqual(rect.height, 4);

		rect.width = 5;
		Assert.assert(rect == [7, 7, 11, 10]);
		Assert.assertEqual(rect.width, 5);
		Assert.assertEqual(rect.height, 4);

		rect.height = 6;
		Assert.assert(rect == [7, 7, 11, 12]);
		Assert.assertEqual(rect.width, 5);
		Assert.assertEqual(rect.height, 6);
	}

	override public function run() {
		test_recti_boundRect();
		test_recti_points();
		test_recti_split_horizontal();
		test_recti_split_vertical();
		test_recti_setters();
	}
}
