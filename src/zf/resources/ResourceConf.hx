package zf.resources;

typedef ResourceConf = {
	public var spritesheets: Array<{
		public var path: String;
	}>;

	public var fonts: Array<{
		public var path: String;
	}>;
	public var sounds: Array<{
		public var path: String;
	}>;
	public var languages: Array<{
		public var path: String;
	}>;
}

enum ResourceSource {
	Pak;
	Dir;
}
