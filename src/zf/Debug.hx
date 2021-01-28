package zf;

import haxe.macro.Expr;

class Debug {
    macro public static function debug(e: Expr) {
#if debug
        return macro {$e;};
#else
        return macro {};
#end
    }
}
