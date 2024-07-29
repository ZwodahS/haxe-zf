package tests.zf.classbuilder;

import zf.Assert;

class TestClassBuilder extends TestCase {
	public static final Name = "TestClassBuilder";

	override public function get_name(): String {
		return Name;
	}

	override public function run() {
		testClassBuilder1();
	}

	public function testClassBuilder1() {
		final object1 = new Object1({x: 3});
		Assert.assert(object1.x == 3);

		object1.conf.x = null;
		Assert.assert(object1.x == null);

		object1.conf = null;
		Assert.assert(object1.x == null);
	}
}
