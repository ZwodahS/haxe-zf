package zf.userdata;

using zf.ds.ArrayExtensions;

#if sys
import sys.FileSystem;
#end

import haxe.io.Path;

/**
	UserData is a simple wrapper to handle the saving of data between local file storage and js local storage.
**/
class UserData {
	/**
		The root directory of the userdata.
	**/
	public var rootDir: String;

	/**
		the storage name of js, use unique paths to ensure no collision with others, i.e itch path
	**/
	public var jsName: String;

	public function new(jsName: String, rootDir: String = "userdata") {
		this.rootDir = rootDir;
		this.jsName = jsName;
	}

	/**
		Check if the data at this path exists
	**/
	public function exists(pathString: String): Bool {
#if (!sys && !js)
		Logger.warn("Saving not supported");
		return false;
#elseif js
		var storage = js.Browser.getLocalStorage();
		if (storage == null) {
			Logger.warn("Saving not enabled");
			return false;
		}
#end

#if sys
		if (!sys.FileSystem.exists(sysPath(pathString))) return false;
		return true;
#elseif js
		var storage = js.Browser.getLocalStorage();
		var content = storage.getItem(jsPath(pathString));
		if (content == null) return false;
		return true;
#end
	}

	/**
		Load data from file
	**/
	public function loadFromPath(pathString: String): UserDataResult {
#if (!sys && !js)
		Logger.warn("Saving not supported");
		return NotSupported;
#elseif js
		var storage = js.Browser.getLocalStorage();
		if (storage == null) {
			Logger.warn("Saving not enabled");
			return BrowserNotEnabled;
		}
#end

		if (!exists(pathString)) return Failure;

#if sys
		var content = sys.io.File.getContent(sysPath(pathString));
#elseif js
		var storage = js.Browser.getLocalStorage();
		var content = storage.getItem(jsPath(pathString));
#else
		return NotSupported;
#end
		return SuccessContent(content);
	}

	public function saveToPath(pathString: String, data: String): UserDataResult {
#if (!sys && !js)
		Logger.warn("Saving not supported");
		return NotSupported;
#elseif js
		var storage = js.Browser.getLocalStorage();
		if (storage == null) {
			Logger.warn("Saving not enabled");
			return BrowserNotEnabled;
		}
#end

#if sys
		// if sys, we will need to put all these data in a specific folder.
		// i.e. in Mac it may be in Documents
		// for now we will put it in a data folder in the same directory as the runtime
		pathString = sysPath(pathString);
#end

		var path = new haxe.io.Path(pathString);
		// Not sure if this works on Windows yet
		var directory = path.dir;
		var filename = path.file;

		// if local filesystem, create directory if not exists
#if sys
		if (!sys.FileSystem.exists(directory)) {
			sys.FileSystem.createDirectory(directory);
		}
#end

#if sys
		sys.io.File.saveContent(pathString, data);
		return Success;
#elseif js
		var storage = js.Browser.getLocalStorage();
		storage.setItem(jsPath(pathString), data);
		return Success;
#else
		return NotSupported;
#end
	}

	inline function sysPath(path: String): String {
		return '${rootDir}/${path}';
	}

	inline function jsPath(path: String): String {
		// for js, we should prepend a name to namespace it
		return '${this.jsName}/${path}';
	}

	/**
		create directory if not exist. Does nothing in jS
	**/
	public function createDirectory(path: String) {
#if sys
		final actualPath = [this.rootDir, path];
		final actualPathString = Path.join(actualPath);
		if (!FileSystem.exists(actualPathString)) FileSystem.createDirectory(actualPathString);
#end
	}

	public function deleteDirectory(path: String): UserDataResult {
#if sys
		final actualPath = [this.rootDir, path];
		final actualPathString = Path.join(actualPath);
		if (FileSystem.exists(actualPathString)) FileSystem.deleteDirectory(actualPathString);
#end
		return Success;
	}

	public function deleteFile(path: String): UserDataResult {
#if (!sys && !js)
		Logger.warn("Saving not supported");
		return NotSupported;
#elseif js
		var storage = js.Browser.getLocalStorage();
		if (storage == null) {
			Logger.warn("Saving not enabled");
			return BrowserNotEnabled;
		}
#end

		if (!exists(path)) return Failure;
#if sys
		FileSystem.deleteFile(sysPath(path));
#elseif js
		final storage = js.Browser.getLocalStorage();
		storage.removeItem(jsPath(path));
#end
		return Success;
	}

	public function init() {
		createDirectory("");
	}
}
