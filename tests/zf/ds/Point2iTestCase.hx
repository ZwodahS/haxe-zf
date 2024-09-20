package tests.zf.ds;

import zf.Point2i;
import zf.Assert;

import zf.Point2i.Point2iImpl;

class Point2iTestCase extends TestCase {
	public static final Name = "Point2iTestCase";

	override public function get_name(): String {
		return Name;
	}

	override public function run() {
		testObjectPool();
	}

	function testObjectPool() {
		final s = Point2i.alloc(1, 2);
		Assert.assert(s.x == 1);
		Assert.assert(s.y == 2);
		s.dispose();

		final s = Point2i.alloc(5, 6);
		Assert.assert(s.x == 5);
		Assert.assert(s.y == 6);
		s.dispose();

		Assert.assert(Point2iImpl.__poolCount__ == 1);
		@:privateAccess final poolObj = Point2iImpl.__pool__;
		Assert.assert(poolObj.x == 0);
		Assert.assert(poolObj.y == 0);
		final s: Point2i = [1, 2];
		Assert.assert(Point2iImpl.__poolCount__ == 0);
		Assert.assert(s.x == 1);
		Assert.assert(s.y == 2);
		Assert.assert(poolObj.x == 1);
		Assert.assert(poolObj.y == 2);
		s.dispose();
	}
}
