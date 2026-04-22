package zf;

#if macro
import haxe.macro.PositionTools;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

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

	/**
		A expr builder that allows adding meta data to block of code.

		Currently supports

		1. @:dispose - automatically dispose the object at the end of the code.

		# Additional Notes

		Currently the case for middle return is not handled.
		This is a limitation at the moment. If there is a need, then it can be implemented.

		Secondly, because the expr is within a block, variable declaration is scoped.
		Might be tricky in some cases. This is a feature, not a bug.
	**/
	macro public static function expr(original: Expr) {
		final handleDisposes = [];
		final exprs = [];

		original.iter((e) -> {
			switch (e.expr) {
				case EMeta(d, ee):
					// we will always add the expression back to the list
					exprs.push(e);
					if (d.name == ":dispose") {
						switch (ee.expr) {
							case EVars(vars):
								handleDisposes.push(vars[0].name);
							default:
						}
					}
				default:
					// if there is no meta, will just use it as is.
					exprs.push(e);
			}
		});

		for (d in handleDisposes) {
			exprs.push(macro {
				if ($i{d} != null) cast($i{d}, zf.Disposable).dispose();
			});
		}

		return macro $b{exprs};
	}
}
/**
	Wed 13:14:37 22 Apr 2026
	Hx.expr is really dangerous slipperly slope.
	I need to be careful with how much code I build vs write.
	This however does open up a lot of option for code generation.
**/
