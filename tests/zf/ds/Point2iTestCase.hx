package tests.zf.ds;

import zf.Point2i;
import zf.serialise.*;
import zf.Identifiable;
import zf.Assert;

import zf.Point2i.Point2iImpl;

#if !macro @:build(zf.macros.Serialise.build()) #end
class A implements Serialisable {

	@:serialise public var pt: Point2i;

	public function new() {
	}
}

class Point2iTestCase extends TestCase {
	public static final Name = "Point2iTestCase";

	override public function get_name(): String {
		return Name;
	}

	override public function run() {
		testObjectPool();
		testSerialise();
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

	function testSerialise() {
		final a = new A();
		a.pt = Point2i.alloc(3, 3);

		final ctx = new SerialiseContext();
		final data = a.toStruct(ctx);
		Assert.assert(data.pt.x == 3);
		Assert.assert(data.pt.y == 3);
	}
}
