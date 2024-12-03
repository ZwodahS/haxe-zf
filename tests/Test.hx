package tests;

import tests.zf.ds.*;
import tests.zf.*;

class Test extends TestRunner {
	public function new() {
		super();

		zf.Logger.init();
		zf.Logger.addConsoleLogger();

		// we will still load all the test cases
		CompileTime.importPackage("tests");
		final classes = CompileTime.getAllClasses('tests', true, TestCase);
		for (c in classes) {
			add(Type.createInstance(c, []));
		}
	}

	public static function main() {
		hxd.Res.initLocal();
		new Test().run();
	}
}
