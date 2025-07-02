package zf;

#if macro
import haxe.macro.PositionTools;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Hx {
	macro public static function swap(a, b) {
		return macro {var v = $a; $a = $b; $b = v;};
	}

	macro public static function benchmark(expr: Expr, tag: String = null) {
#if debug
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			final t1 = haxe.Timer.stamp();
			$expr;
			final diff = haxe.Timer.stamp() - t1;
			var percentOfFrame = zf.StringUtils.formatFloat(diff / (1 / 60) * 100, 1);
			haxe.Log.trace('[Benchmark ' + $v{tag} + '] took ${diff}s, ${percentOfFrame}% of frame', null);
		}
#else
		return expr;
#end
	}
}
