package zf;

import haxe.macro.Expr;
import haxe.macro.PositionTools;
import haxe.macro.Context;

class Debug {
	macro public static function debug(e: Expr) {
#if debug
		return macro {$e;};
#else
		return macro {};
#end
	}

	macro public static function breakpoint() {
#if debugger
		// this is currently hardcoded to find "src/ and remove everything before it
		// TOFIX: need to find a way to dynamically resolve the actual path to the file
		var location = PositionTools.toLocation(Context.currentPos());
		var path = location.file.toString();
		var i = path.lastIndexOf("src/");
		if (i != -1) path = path.substr(i + 4);
		var locationString = path + ":" + location.range.start.line;
		// This is also hackish, because I am using a Makefile to delete the .breakpoints first before
		// compiling. Need to find a way perhaps to do this automatically ?
		var fo = sys.io.File.append(".breakpoints", false);
		fo.write(haxe.io.Bytes.ofString('break ${locationString}\n'));
		fo.close();

		// just print out so I know it is logging
		return macro {haxe.Log.trace('${locationString}: Breakpoint');}
#else
		return macro {}
#end
	}

	static var TimerCounter: Map<String, Float>;

	public static function time(id: String, print: Null<Bool> = null, remove: Null<Bool> = null): Float {
		if (Debug.TimerCounter == null) Debug.TimerCounter = new Map<String, Float>();
		var c = Debug.TimerCounter[id];
		var now = haxe.Timer.stamp();
		if (remove == null && c != null) remove = true;
		if (print == null && c != null) print = true;
		if (remove) {
			Debug.TimerCounter.remove(id);
		} else {
			Debug.TimerCounter[id] = now;
		}
		var diff = c != null ? now - c : 0;
		if (print) haxe.Log.trace('[Timer: ${id}] took: ${diff}s', null);
		return diff;
	}

	static var counter: Int = 0;
}
