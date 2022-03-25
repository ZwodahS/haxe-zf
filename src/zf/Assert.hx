package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

/**
	Macro assert function.

	This can be use directly for actual assertion, or in a test case by catching AssertionFail.
	Do not use function with side effect in the expression as they may result in different behaviors
	when the assertion is not present.
**/
class Assert {
	macro public static function assert(expression: ExprOf<Bool>, terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final msg = '"${ExprTools.toString(expression)}"';
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if (!($e{expression})) {
					throw new zf.exceptions.AssertionFail('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		} else {
			return macro {
				if (!($e{expression})) {
					haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		}
#end
	}

	macro public static function assertTrue(expression: ExprOf<Bool>, terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final msg = '"${ExprTools.toString(expression)}"';
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if (!($e{expression})) {
					throw new zf.exceptions.AssertionFail('['
						+ $v{locationString} + '] Assertion failed: ' + $v{msg} + ' is not true');
				}
			};
		} else {
			return macro {
				if (!($e{expression})) {
					haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: ' + $v{msg} + ' is not true');
				}
			};
		}
#end
	}

	/**
		Assert that 2 values are equal.
	**/
	macro public static function assertEqual<T>(v1: ExprOf<T>, v2: ExprOf<T>, terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final msg = '${ExprTools.toString(v1)} == ${ExprTools.toString(v2)}';
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if ($e{v1} != $e{v2}) {
					throw new zf.exceptions.AssertionFail('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		} else {
			return macro {
				if ($e{v1} != $e{v2}) {
					haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		}
#end
	}

	/**
		Assert that 2 values are not equal.
	**/
	macro public static function assertNotEqual<T>(v1: ExprOf<T>, v2: ExprOf<T>, terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final msg = '${ExprTools.toString(v1)} != ${ExprTools.toString(v2)}';
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if ($e{v1} == $e{v2}) {
					throw new zf.exceptions.AssertionFail('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		} else {
			return macro {
				if ($e{v1} == $e{v2}) {
					haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		}
#end
	}

	/**
		Assert a value is not null
	**/
	macro public static function assertNotNull(v1: ExprOf<Dynamic>, terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final msg = '${ExprTools.toString(v1)} unexpectedly null';
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if (${v1} == null) {
					throw new zf.exceptions.AssertionFail('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		} else {
			return macro {
				if (${v1} == null) {
					haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		}
#end
	}

	/**
		Assert a value is null
	**/
	macro public static function assertNull(v1: ExprOf<Dynamic>, terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final msg = '${ExprTools.toString(v1)} is not null';
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if (${v1} != null) {
					throw new zf.exceptions.AssertionFail('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		} else {
			return macro {
				if (${v1} != null) {
					haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: ' + $v{msg});
				}
			};
		}
#end
	}

	macro public static function unreachable(terminate: Bool = true) {
#if no_assertion
		return macro {};
#else
		final location = PositionTools.toLocation(Context.currentPos());
		final locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				throw new zf.exceptions.AssertionFail('['
					+ $v{locationString} + '] Assertion failed: Should be unreachable.');
			};
		} else {
			return macro {
				haxe.Log.trace('[' + $v{locationString} + '] Assertion failed: Should be unreachable.');
			};
		}
#end
	}
}
