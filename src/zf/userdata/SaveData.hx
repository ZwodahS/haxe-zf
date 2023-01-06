package zf.userdata;

/**
	@stage:stable
**/
class SaveData<T: StructData> {
	public final profile: UserProfile;
	public final path: String;

	public function new(profile: UserProfile, path: String) {
		this.profile = profile;
		this.path = path;
	}

	public function save(data: T): UserDataResult {
		final struct = data.toStruct();
#if sys
		final jsonString = haxe.format.JsonPrinter.print(struct, "  ");
#else
		final jsonString = haxe.Json.stringify(struct);
#end
		return this.profile.save(this.path, jsonString);
	}

	public function load(data: T): Bool {
		final result = this.profile.load(this.path);
		switch (result) {
			case SuccessContent(content):
				final jsonData = haxe.Json.parse(content);
				return data.fromStruct(jsonData);
			default:
				return false;
		}
	}
}
