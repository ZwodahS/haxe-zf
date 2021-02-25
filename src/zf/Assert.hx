package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class Assert {
	macro public static function assert(e: ExprOf<Bool>, terminate: Bool = true, ?msg: String) {
		// taken from https://gist.github.com/bendmorris/7695f36dbc8c2968c2a5d6bdde5f0592
#if no_assertion
		return macro {};
#else
		msg = msg != null ? msg : ExprTools.toString(e);
		var location = PositionTools.toLocation(Context.currentPos());
		var locationString = location.file + ":" + location.range.start.line;
		if (terminate) {
			return macro {
				if (!$e) throw '[${locationString}] Assertion failed: ${msg}';
			};
		} else {
			return macro {
				if (!$e) trace('[${locationString}] Assertion failed: ${msg}');
			};
		}
#end
	}

	// using this need to be put behind #if !no_assertion, so that the 2 value does not get evaluated
	// when it is a function.
	public static function assertEqual(v1: Dynamic, v2: Dynamic, ?additionalMsg: String,
			?pos: haxe.PosInfos) {
		if (v1 != v2) {
			additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
			var msg = ' ${v1} != ${v2} ${additionalMsg}';
			throw '[${pos.fileName}:${pos.lineNumber}] Assertion failed: ${msg}';
		}
	}

	public static function valueIn<T>(v: T, values: Array<T>): Bool {
		for (value in values) {
			if (v == value) return true;
		}
		return false;
	}

	macro public static function unreachable(terminate: Bool = true, ?msg: String) {
#if no_assertion
		return macro {};
#else
		var location = PositionTools.toLocation(Context.currentPos());
		var locationString = location.file + ":" + location.range.start.line;
		msg = msg == null ? "" : ': ${msg}';
		if (terminate) {
			return macro {
				throw '[${locationString}] Assertion failed: Should be unreachable${msg}';
			};
		} else {
			return macro {
				trace('[${locationString}] Assertion failed: Should be unreachable${msg}');
			};
		}
#end
	}
}
