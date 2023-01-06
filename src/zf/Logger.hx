package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;

import zf.exceptions.AssertionFail;

/**
	@stage:stable
**/
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

	macro public static function deprecated() {
#if !debug
		return macro {};
#else
		var location = PositionTools.toLocation(Context.currentPos());
		final tag = location.file + ":" + location.range.start.line;
		return macro {
			haxe.Log.trace($v{tag} + ' [Debug] this code is deprecated.');
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

	inline public static function exception(e: haxe.Exception, stackItems: Array<haxe.CallStack.StackItem> = null) {
#if debug
		if (Std.isOfType(e, AssertionFail)) {
			haxe.Log.trace(e.message, null);
		} else {
			for (es in haxe.CallStack.exceptionStack()) trace(es);
			haxe.Log.trace(e, null);
			if (stackItems != null) {
				for (s in stackItems) {
					haxe.Log.trace('Called from ${stackItemToString(s)}', null);
				}
			} else {
				haxe.Log.trace(e.stack, null);
			}
		}
#end
	}

	public static function stackItemToString(s: haxe.CallStack.StackItem) {
		switch (s) {
			case Module(m):
				return '${m}';
			case FilePos(s, file, line, _):
				if (s == null) {
					return '${file}:${line}';
				} else {
					return '${stackItemToString(s)} (${file}:${line})';
				}
			case Method(cn, method):
				if (cn == null) return '${method}';
				return '${cn}.${method}';
			case LocalFunction(v):
				return '$' + '${v}';
			case CFunction:
				return 'CFunction';
		}
	}
}
