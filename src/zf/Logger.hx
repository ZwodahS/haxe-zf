package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;

class Logger {
    macro public static function error(msg: String) {
#if (!loggingLevel || loggingLevel < 10)
        return macro {};
#else
        var location = PositionTools.toLocation(Context.currentPos());
        var locationString = location.file + ":" + location.range.start.line;
        return macro {
            haxe.Log.trace('${locationString}: [Error] ${msg}', null);
        }
#end
    }

    macro public static function warn(msg: String) {
#if (!loggingLevel || loggingLevel < 15)
        return macro {};
#else
        var location = PositionTools.toLocation(Context.currentPos());
        var locationString = location.file + ":" + location.range.start.line;
        return macro {
            haxe.Log.trace('${locationString}: [Warn] ${msg}', null);
        }
#end
    }

    macro public static function info(msg: String) {
#if (!loggingLevel || loggingLevel < 20)
        return macro {};
#else
        var location = PositionTools.toLocation(Context.currentPos());
        var locationString = location.file + ":" + location.range.start.line;
        return macro {
            haxe.Log.trace('${locationString}: [Info] ${msg}', null);
        }
#end
    }

    macro public static function debug(msg: String) {
#if (!loggingLevel || loggingLevel < 30)
        return macro {};
#else
        var location = PositionTools.toLocation(Context.currentPos());
        var locationString = location.file + ":" + location.range.start.line;
        return macro {
            haxe.Log.trace('${locationString}: [Debug] ${msg}', null);
        }
#end
    }
}
