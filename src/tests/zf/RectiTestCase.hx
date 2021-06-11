package tests.zf;

import zf.Recti;
import zf.tests.TestCase;

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
}
