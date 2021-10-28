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
		// create the profiles in case it doesn't exists
		savefile.userdata.createDirectory("profiles");
		// load settings
		final loadResult = this.savefile.userdata.loadFromPath("profiles/settings.json");
		switch (loadResult) {
			case SuccessContent(data):
				final settings: UserProfilesSettings = data;
			default:
#if sys
				final jsonString = haxe.format.JsonPrinter.print({profiles: []}, "  ");
#else
				final jsonString = haxe.Json.stringify({profiles: []});
#end
				this.savefile.userdata.saveToPath("profiles/settings.json", jsonString);
		}
	}

	public function getProfile(profileName: String = "default"): UserProfile {
		if (profiles[profileName] == null) {
			final profile = new UserProfile(this, profileName);
			profile.init();
			this.profiles[profileName] = profile;
			save();
		}
		return this.profiles[profileName];
	}

	/**
		Save the list of profiles
	**/
	public function save() {
		final struct = {
			profiles: [for (key => _ in this.profiles) key],
		}
#if sys
		final jsonString = haxe.format.JsonPrinter.print(struct, "  ");
#else
		final jsonString = haxe.Json.stringify(struct);
#end
		this.savefile.userdata.saveToPath("profiles/settings.json", jsonString);
	}
}
