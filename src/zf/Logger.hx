package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;

class Logger {
	macro public static function error(msg: String, tag: String = null) {
#if (!loggingLevel || loggingLevel < 10)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace('${tag}: [Error] ${msg}', null);
		}
#end
	}

	macro public static function warn(msg: String, tag: String = null) {
#if (!loggingLevel || loggingLevel < 15)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace('${tag}: [Warn] ${msg}', null);
		}
#end
	}

	macro public static function info(msg: String, tag: String = null) {
#if (!loggingLevel || loggingLevel < 20)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace('${tag}: [Info] ${msg}', null);
		}
#end
	}

	macro public static function debug(msg: String, tag: String = null) {
#if (!loggingLevel || loggingLevel < 30)
		return macro {};
#else
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			haxe.Log.trace('${tag}: [Debug] ${msg}', null);
		}
#end
	}
}
