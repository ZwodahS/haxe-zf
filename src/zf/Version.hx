package zf;

/**
	@stage:stable
**/
class Version {
	public var major: Int = 0;
	public var minor: Int = 0;
	public var patch: Int = 0;

	public function new(major: Int, minor: Int, patch: Int) {
		this.major = major;
		this.minor = minor;
		this.patch = patch;
	}

	public function toString(): String {
		final s = [];
		s.push('${this.major}');
		s.push('${this.minor}');
		s.push('${this.patch}');
		return s.join(".");
	}

	public static function fromString(s: String): Version {
		final split = s.split(".");
		return new Version(Std.parseInt(split[0]), Std.parseInt(split[1]), Std.parseInt(split[2]));
	}
}
