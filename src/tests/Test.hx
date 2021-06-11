package tests;

import zf.tests.TestCase;
import zf.tests.TestRunner;

import tests.zf.ds.*;
import tests.zf.*;

class Test extends TestRunner {
	public function new() {
		super();
		add(new RectiTestCase());
		add(new Vector2DRegionTestCase());
	}

	public static function main() {
		hxd.Res.initLocal();
		new Test().run();
	}
}
