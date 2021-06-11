package tests.zf.ds;

import zf.Point2i;
import zf.ds.Vector2D;
import zf.ds.Vector2DRegion;
import zf.tests.TestCase;

class Vector2DRegionTestCase extends TestCase {
	function test_basic_region_iteration() {
		var grid = new Vector2D<String>([10, 10], "#");
		var r = new Vector2DRegion<String>(grid);

		// set up the coord system
		for (pt => value in r.iterate()) {
			r.set(pt.x, pt.y, '${pt.x},${pt.y}');
		}

		var r2 = r.subRegion(2, 2, 2, 2);
		for (pt => value in r2.iterate()) {
			assertEqual(value, '${pt.x + 2},${pt.y + 2}');
		}
	}

	function test_out_of_bound_region() {
		var grid = new Vector2D<String>([10, 10], "#");
		var r = new Vector2DRegion<String>(grid);

		// set up the coord system
		for (pt => value in r.iterate()) {
			r.set(pt.x, pt.y, '${pt.x},${pt.y}');
		}

		var r2 = r.subRegion(9, 9, 2, 2);
		var output: Array<String> = [];
		for (pt => value in r2.iterate()) {
			output.push(value);
		}
		assertEqual(output.length, 1);
		assertEqual(output[0], '9,9');
		assertEqual(r2.size.x, 1);
		assertEqual(r2.size.y, 1);
	}

	function test_subregion_of_subregion() {
		var grid = new Vector2D<String>([10, 10], "#");
		var r = new Vector2DRegion<String>(grid);

		// set up the coord system
		for (pt => value in r.iterate()) {
			r.set(pt.x, pt.y, '${pt.x},${pt.y}');
		}

		var r2 = r.subRegion(2, 2, 6, 6);
		var output: Array<String> = [];
		for (pt => value in r2.iterate()) {
			output.push(value);
		}
		assertEqual(output.length, 36);

		var r3 = r2.subRegion(1, 1, 3, 3);
		assertEqual(r3.get(0, 0), '3,3');
		assertEqual(r3.get(3, 0), null);
		assertEqual(r3.get(0, 3), null);

		var r4 = r2.subRegion(5, 5, 3, 3);
		assertEqual(r4.size.x, 1);
		assertEqual(r4.size.y, 1);
		assertEqual(r4.get(0, 0), "7,7");
		assertEqual(r4.get(1, 0), null);
		assertEqual(r4.get(0, 1), null);
	}
}
