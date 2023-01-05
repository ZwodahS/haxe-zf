package tests.zf;

import zf.Point2i;
import zf.Recti;
import zf.deprecated.tests.TestCase;

class RectiTestCase extends TestCase {
	function test_recti_boundRect() {
		var rect1 = new Recti(4, 5, 8, 9);
		var rect2 = new Recti(5, 5, 6, 6);

		var bound = rect1.boundRect(rect2);
		assertEqual(bound == rect2, true);

		var rect3 = new Recti(2, 2, 6, 6);
		var bound = rect1.boundRect(rect3);
		assertEqual(bound == new Recti(4, 5, 6, 6), true);

		var rect4 = new Recti(2, 2, 3, 3);
		var bound = rect1.boundRect(rect4);
		assertEqual(bound == new Recti(4, 5, 4, 5), true);

		var rect5 = new Recti(9, 9, 12, 12);
		var bound = rect1.boundRect(rect5);
		assertEqual(bound == new Recti(8, 9, 8, 9), true);
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
		assertEqual(outcome.length, points.length);
		for (ind in 0...outcome.length) {
			assertEqual(points[ind] == outcome[ind], true);
		}
	}

	function test_recti_split_hortizontal() {
		var rect = new Recti(0, 0, 9, 9);
		var rs = rect.splitHorizontal(5);
		assertTrue(rs[0] == new Recti(0, 0, 4, 9), '${rs[0]} != [0, 0, 4, 9]');
		assertTrue(rs[1] == new Recti(5, 0, 9, 9), '${rs[1]} != [5, 0, 9, 9]');

		var rs = rect.splitHorizontal(9);
		assertTrue(rs[0] == new Recti(0, 0, 8, 9), '${rs[0]} != [0, 0, 9, 9]');
		assertTrue(rs[1] == new Recti(9, 0, 9, 9), '${rs[1]} != [9, 0, 9, 9]');

		var rs = rect.splitHorizontal(0);
		assertTrue(rs[0] == null, '${rs[0]} != null');
		assertTrue(rs[1] == new Recti(0, 0, 9, 9), '${rs[1]} != [0, 0, 9, 9]');

		var rs = rect.splitHorizontal(10);
		assertTrue(rs[0] == new Recti(0, 0, 9, 9), '${rs[0]} != [0, 0, 9, 9]');
		assertTrue(rs[1] == null, '${rs[1]} != null');
	}

	function test_recti_split_vertical() {
		var rect = new Recti(0, 0, 9, 9);
		var rs = rect.splitVertical(5);
		assertTrue(rs[0] == new Recti(0, 0, 9, 4), '${rs[0]} != [0, 0, 9, 4]');
		assertTrue(rs[1] == new Recti(0, 5, 9, 9), '${rs[1]} != [0, 5, 9, 9]');

		var rs = rect.splitVertical(9);
		assertTrue(rs[0] == new Recti(0, 0, 9, 8), '${rs[0]} != [0, 0, 9, 8]');
		assertTrue(rs[1] == new Recti(0, 9, 9, 9), '${rs[1]} != [0, 9, 9, 9]');

		var rs = rect.splitVertical(0);
		assertTrue(rs[0] == null, '${rs[0]} != null');
		assertTrue(rs[1] == new Recti(0, 0, 9, 9), '${rs[1]} != [0, 0, 9, 9]');

		var rs = rect.splitVertical(10);
		assertTrue(rs[0] == new Recti(0, 0, 9, 9), '${rs[0]} != [0, 0, 9, 9]');
		assertTrue(rs[1] == null, '${rs[1]} != null');
	}

	function test_recti_setters() {
		var rect = new Recti(0, 0, 2, 3); // this is a 3 by 4 rect

		rect.left = 3;
		assertTrue(rect == [3, 0, 5, 3], '${rect} != [3, 0, 5, 3]');
		assertEqual(rect.width, 3);
		assertEqual(rect.height, 4);

		rect.top = 4;
		assertTrue(rect == [3, 4, 5, 7], '${rect} != [3, 4, 5, 7]');
		assertEqual(rect.width, 3);
		assertEqual(rect.height, 4);

		rect.right = 9;
		assertTrue(rect == [7, 4, 9, 7], '${rect} != [7, 4, 9, 7]');
		assertEqual(rect.width, 3);
		assertEqual(rect.height, 4);

		rect.bottom = 10;
		assertTrue(rect == [7, 7, 9, 10], '${rect} != [7, 7, 9, 10]');
		assertEqual(rect.width, 3);
		assertEqual(rect.height, 4);

		rect.width = 5;
		assertTrue(rect == [7, 7, 11, 10], '${rect} != [7, 7, 11, 10]');
		assertEqual(rect.width, 5);
		assertEqual(rect.height, 4);

		rect.height = 6;
		assertTrue(rect == [7, 7, 11, 12], '${rect} != [7, 7, 11, 12]');
		assertEqual(rect.width, 5);
		assertEqual(rect.height, 6);
	}
}
