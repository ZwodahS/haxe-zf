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
        var assertion = ExprTools.toString(e);
        var location = PositionTools.toLocation(Context.currentPos());
        var locationString = location.file + ":" + location.range.start.line;
        if (terminate) {
            return macro {
                if (!$e) throw '[${locationString}] Assertion failed: ${msg} "' + $v{assertion} + '"';
            };
        } else {
            return macro {
                if (!$e) trace('[${locationString}] Assertion failed: ${msg} "' + $v{assertion} + '"');
            };
        }
#end
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
