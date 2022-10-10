package zf.userdata;

import haxe.io.Path;

import zf.userdata.UserData;

typedef UserProfilesSettings = {
	profiles: Array<String>,
}

class UserProfiles {
	public final savefile: Savefile;
	public final profiles: Map<String, UserProfile>;

	public function new(savefile: Savefile) {
		this.savefile = savefile;
		this.profiles = new Map<String, UserProfile>();
	}

	public function init() {
		// create the profiles directory in case it doesn't exists
		savefile.userdata.createDirectory("profiles");
	}

	public function getProfile(profileName: String = "default", create: Bool = true): UserProfile {
		final folderExists = this.savefile.userdata.exists('profiles/${profileName}');
		if (profiles[profileName] == null && (folderExists == true || create == true)) {
			final profile = new UserProfile(this, profileName);
			profile.init();
			this.profiles[profileName] = profile;
		}
		return this.profiles[profileName];
	}
}
/**
	Mon 13:28:03 10 Oct 2022

	Removed settings.json from profiles/ path.
	This should be handled by each game since they might have different saving requirement.
	For example,
	games that are profile based might opt to have a final set of profile.
	games that are more savefile based might opt to use each profile as a world save.
	Some games might even choose to do both, like having different world save tied to different profiles
		and also allow for multiple profiles. The requirements for these are hard to know so I don't want to
		put it in zf yet.
**/
