package zf.userdata;

import haxe.io.Path;

#if sys
import sys.FileSystem;
#end

/**
	@stage:stable

	A simple save file implementation, wrapped around UserData

	This is opinionated, with a semi fixed folder structure.

	/ - the root directory of the userdata

	/settings.json - contains the settings for the game
	/profiles/settings.json
	/profiles/{name} - contains a player profiles
	/profiles/{name}/settings.json - the settings for the profiles
	/profiles/{name}/worlds/{worldname} - contains the run data for the player profiles
	/profiles/{name}/worlds/{worldname}/... - various data
**/
class Savefile {
	public final rootDir: String;
	public final userdata: UserData;
	public final userProfiles: UserProfiles;

	public function new(jsName: String, rootDir: String = "userdata") {
		this.userdata = new UserData(jsName, rootDir);
		this.rootDir = rootDir;

		this.userProfiles = new UserProfiles(this);
	}

	/**
		Init the various folder.

		On JS, this will not do anything.
	**/
	public function init() {
#if sys
		this.userdata.init();
		this.userProfiles.init();
#end
	}
}
