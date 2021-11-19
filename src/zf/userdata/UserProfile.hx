package zf.userdata;

import haxe.io.Path;

import zf.userdata.UserData;

class UserProfile {
	public final userProfiles: UserProfiles;
	public final savefile: Savefile;
	public final profileName: String;

	public function new(userProfiles: UserProfiles, profileName: String) {
		this.userProfiles = userProfiles;
		this.savefile = userProfiles.savefile;
		this.profileName = profileName;
	}

	public function init() {
		this.savefile.userdata.createDirectory(Path.join(["profiles", this.profileName]));
	}

	public function save(pathString: String, data: String): UserDataResult {
		return this.savefile.userdata.saveToPath(path(pathString), data);
	}

	public function load(pathString: String): UserDataResult {
		return this.savefile.userdata.loadFromPath(path(pathString));
	}

	public function exists(pathString: String): Bool {
		return this.savefile.userdata.exists(path(pathString));
	}

	public function createDirectory(pathString: String) {
		return this.savefile.userdata.createDirectory(path(pathString));
	}

	public function deleteDirectory(pathString: String) {
		return this.savefile.userdata.deleteDirectory(path(pathString));
	}

	public function deleteFile(pathString: String) {
		return this.savefile.userdata.deleteFile(path(pathString));
	}

	inline function path(pathString: String): String {
		return Path.join(["profiles", this.profileName, pathString]);
	}

	public function loadStruct(path: String): UserDataResult {
		final result = load(path);
		switch (result) {
			case SuccessContent(content):
				try {
					final jsonData = haxe.Json.parse(content);
					return SuccessContent(jsonData);
				} catch (e) {
					Logger.exception(e);
					return FailureReason('parse-error', "Fail to parse data");
				}
			default:
				return result;
		}
	}

	public function saveStruct(path: String, struct: Dynamic): UserDataResult {
		try {
#if sys
			final jsonString = haxe.format.JsonPrinter.print(struct, "  ");
#else
			final jsonString = haxe.Json.stringify(struct);
#end
			return save(path, jsonString);
		} catch (e) {
			return FailureReason('Parsing', e.toString());
		}
	}

	public function saveStructs(structs: Map<String, Dynamic>): Bool {
		for (path => struct in structs) {
			final result = saveStruct(path, struct);
			switch (result) {
				case NotSupported:
					return false;
				case BrowserNotEnabled:
					return false;
				case Failure:
					return false;
				case FailureReason(r, m):
					return false;
				default:
			}
		}
		return true;
	}
}
