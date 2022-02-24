package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;

import zf.exceptions.AssertionFail;

class Logger {
	macro public static function error(msg: ExprOf<String>, tag: String = null) {
#if (!loggingLevel || loggingLevel < 10)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace($v{tag} + ' [Error] ' + $e{msg}, null);
		}
#end
	}

	macro public static function warn(msg: ExprOf<String>, tag: String = null) {
#if (!loggingLevel || loggingLevel < 15)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace($v{tag} + ' [Warn] ' + $e{msg}, null);
		}
#end
	}

	macro public static function info(msg: ExprOf<String>, tag: String = null) {
#if (!loggingLevel || loggingLevel < 20)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace($v{tag} + ' [Info] ' + $e{msg}, null);
		}
#end
	}

	macro public static function debug(msg: ExprOf<String>, tag: String = null) {
#if (!loggingLevel || loggingLevel < 30)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace($v{tag} + ' [Debug] ' + $e{msg}, null);
		}
#end
	}

	inline public static function exception(e: haxe.Exception) {
#if debug
		if (Std.isOfType(e, AssertionFail)) {
			haxe.Log.trace(e.message, null);
		} else {
			for (es in haxe.CallStack.exceptionStack()) trace(es);
			haxe.Log.trace(e, null);
			trace(e.stack);
		}
#end
	}
}
