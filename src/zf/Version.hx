package zf;

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
		return new Version(Std.int(split[0]), Std.int(split[1]), Std.int(split[2]));
	}
}
