package common;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class Assert {
    macro public static function assert(e: ExprOf<Bool>, ?msg: String) {
        // taken from https://gist.github.com/bendmorris/7695f36dbc8c2968c2a5d6bdde5f0592
#if no_assertion
        return macro {};
#else
        var assertion = ExprTools.toString(e);
        return macro {
            if (!$e) throw 'Assertion failed: ${msg} "' + $v{assertion} + '"';
        };
#end
    }
}
