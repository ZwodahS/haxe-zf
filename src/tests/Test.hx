package tests;

import zf.deprecated.tests.TestCase;
import zf.deprecated.tests.TestRunner;

import tests.zf.ds.*;
import tests.zf.*;

class Test extends TestRunner {
	public function new() {
		super();
		add(new RectiTestCase());
		add(new Vector2DRegionTestCase());
		add(new ListExtensionsTestCase());
		add(new DirectionTestCase());
	}

	public static function main() {
		hxd.Res.initLocal();
		new Test().run();
	}
}
