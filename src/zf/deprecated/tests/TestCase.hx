package zf.deprecated.tests;

using StringTools;

/**
	@stage:deprecating
**/
class TestCase {
	var currentContext: String = "";

	public function new() {}

	public function run() {
		var c = Type.getClass(this);
		var className = Type.getClassName(c);
		trace('Running ${className}');
		for (name in Type.getInstanceFields(c)) {
			var field = Reflect.field(this, name);
			var success = false;
			var message: String = null;
			if (name.startsWith("test_") && Reflect.isFunction(field)) {
				try {
					this.currentContext = name;
					Reflect.callMethod(this, field, []);
					success = true;
				} catch (e: zf.exceptions.AssertionFail) {
					success = false;
					message = e.message;
				} catch (e) {
					// error not thrown by assert function
					if (e.message != 'Assertion Fail') {
						trace(e.message);
						trace(e.stack);
					}
					success = false;
				}
				this.currentContext = null;
				if (success) {
					trace('---- Done: ${className}.${name}: <green>Pass</>');
				} else {
					trace('---- Done: ${className}.${name}: <red>Fail</>');
					if (message != null) {
						trace('     <red>Failure</>: ${message}');
					}
				}
			}
		}
	}

	function subTest(subTestId: String, func: Void->Void) {
		var className = Type.getClassName(Type.getClass(this));
		var success = false;
		try {
			func();
			success = true;
		} catch (e) {
			// error not thrown by assert function
			if (e.message != 'Assertion Fail') {
				trace(e.message);
				trace(e.stack);
			}
			success = false;
		}
		if (success) {
			trace('---- Done: SubTest ${className}.${this.currentContext}:${subTestId} <green>Pass</>');
		} else {
			trace('---- Done: SubTest ${className}.${this.currentContext}:${subTestId} <red>Fail</>');
		}
	}

	public function assertTrue(v: Bool, ?additionalMsg: String, ?pos: haxe.PosInfos) {
		if (!v) {
			additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
			var msg = '[AssertTrue] [${pos.fileName}:${pos.lineNumber}]: ${v} is not True ${additionalMsg}';
			trace(msg);
			throw 'Assertion Fail';
		}
	}

	public function assertEqual(v1: Dynamic, v2: Dynamic, ?additionalMsg: String, ?pos: haxe.PosInfos) {
		if (v1 != v2) {
			additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
			var msg = '[AssertEqual] [${pos.fileName}:${pos.lineNumber}]: ${v1} != ${v2} ${additionalMsg}';
			trace(msg);
			throw 'Assertion Fail';
		}
	}

	public function assertNotEqual(v1: Dynamic, v2: Dynamic, ?additionalMsg: String, ?pos: haxe.PosInfos) {
		if (v1 == v2) {
			additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
			var msg = '[AssertNotEqual] [${pos.fileName}:${pos.lineNumber}]: ${v1} == ${v2} ${additionalMsg}';
			trace(msg);
			throw 'Assertion Fail';
		}
	}

	public function assertIn(v1: Dynamic, v2: Iterable<Dynamic>, ?additionalMsg: String, ?pos: haxe.PosInfos) {
		var found = false;
		for (v in v2) {
			if (v1 == v) {
				found = true;
				break;
			}
		}
		if (!found) {
			additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
			var msg = '[AssertIn] [${pos.fileName}:${pos.lineNumber}]: ${v1} not found in ${v2} ${additionalMsg}';
			trace(msg);
			throw 'Assertion Fail';
		}
	}
}

/**
	Wed 22:19:07 04 Jan 2023
	I want to deprecate this eventually.
	Many of the assertion are in the old style, and I should be using Assert.assert instead.
	We will also need to upgrade the TestRunner later.
**/
