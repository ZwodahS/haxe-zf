package zf;

import haxe.macro.PositionTools;
import haxe.macro.Context;

import zf.exceptions.AssertionFail;

interface LoggerInf {
	public function print(logLevel: Int, message: String): Void;
	public function dispose(): Void;
}

class ConsoleLogger implements LoggerInf {
	public var minLogLevel: Null<Int> = null;
	public var maxLogLevel: Null<Int> = null;

	public function new() {}

	public function print(logLevel: Int, message: String) {
		if (this.minLogLevel != null && logLevel < this.minLogLevel) return;
		if (this.maxLogLevel != null && logLevel > this.maxLogLevel) return;
		haxe.Log.trace(message, null);
	}

	public function dispose() {}
}

#if sys
class FileLogger implements LoggerInf {
	public var minLogLevel: Null<Int> = null;
	public var maxLogLevel: Null<Int> = null;
	public var file: sys.io.FileOutput;

	public function new(path: String) {
		try {
			final size = sys.FileSystem.stat(path).size;
			if (size > 10 * 1024 * 1024) { // if log is more than 10 MB, we will just delete it first.
				sys.FileSystem.deleteFile(path);
				Logger.info('log file ${path} too big, deleting it');
			}
		} catch (e) {}
		try {
			this.file = sys.io.File.append(path, false);
		} catch (e) {
			this.file = null;
		}
	}

	public function print(logLevel: Int, message: String) {
		if (this.file == null) return;
		if (this.minLogLevel != null && logLevel < this.minLogLevel) return;
		if (this.maxLogLevel != null && logLevel > this.maxLogLevel) return;
		this.file.writeString(message + "\n");
		this.file.flush();
	}

	public function dispose() {
		if (this.file == null) return;
		try {
			this.file.close();
		} catch (e) {}
	}
}
#end

/**
	@stage:stable
**/
class Logger {
	public static var PadLength: Int = 15;

	public static var loggers: Array<LoggerInf>;

	public static function init() {
		if (Logger.loggers != null) return;
		Logger.loggers = [];
	}

	public static function addConsoleLogger(minLevel: Null<Int> = null, maxLevel: Null<Int> = null) {
		final logger = new ConsoleLogger();
		logger.minLogLevel = minLevel;
		logger.maxLogLevel = maxLevel;
		Logger.loggers.push(logger);
	}

	public static function addFileLogger(path: String, minLevel: Null<Int>, maxLevel: Null<Int>) {
#if sys
		final logger = new FileLogger(path);
		logger.minLogLevel = minLevel;
		logger.maxLogLevel = maxLevel;
		Logger.loggers.push(logger);
#end
	}

	public static function dispose() {
		if (Logger.loggers == null) return;
		for (l in Logger.loggers) l.dispose();
	}

	public static function print(level: Int, message: String) {
		if (Logger.loggers == null) return;
		for (l in Logger.loggers) l.print(level, message);
	}

	/**
		Error
		Log level 100
	**/
	macro public static function error(msg: ExprOf<String>, tag: String = null) {
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			Logger.print(100, StringTools.lpad($v{tag}, " ", Logger.PadLength) + ' [Error] ' + $e{msg});
		}
	}

	/**
		Warn
		Log level 50
	**/
	macro public static function warn(msg: ExprOf<String>, tag: String = null) {
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			Logger.print(50, StringTools.lpad($v{tag}, " ", Logger.PadLength) + ' [Warn] ' + $e{msg});
		}
	}

	/**
		Info
		Log level 25
	**/
	macro public static function info(msg: ExprOf<String>, tag: String = null) {
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			Logger.print(25, StringTools.lpad($v{tag}, " ", Logger.PadLength) + ' [Info] ' + $e{msg});
		}
	}

	/**
		mark part of the code is deprecated
		Log level 40
	**/
	macro public static function deprecated() {
		var location = PositionTools.toLocation(Context.currentPos());
		final tag = location.file + ":" + location.range.start.line;
		return macro {
			Logger.print(40, 'Debug: This code is deprecated');
		}
	}

	/**
		debug
		Log level 0
	**/
	macro public static function debug(msg: ExprOf<String>, tag: String = null) {
		if (tag == null) {
			var location = PositionTools.toLocation(Context.currentPos());
			tag = location.file + ":" + location.range.start.line;
		}
		return macro {
			Logger.print(0, StringTools.lpad($v{tag}, " ", Logger.PadLength) + ' [Debug] ' + $e{msg});
		}
	}

	inline public static function exception(e: haxe.Exception, stackItems: Array<haxe.CallStack.StackItem> = null) {
		if (Std.isOfType(e, AssertionFail)) {
			Logger.print(100, 'Exception: ' + e.message);
		} else {
			for (es in haxe.CallStack.exceptionStack()) trace(es);
			Logger.print(100, 'Exception: ' + e);
			if (stackItems != null) {
				for (s in stackItems) {
					Logger.print(100, 'Called from ${stackItemToString(s)}');
				}
			} else {
				Logger.print(100, e.stack.toString());
			}
		}
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
