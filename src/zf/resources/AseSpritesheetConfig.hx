package zf.resources;

typedef AseSpritesheetConfig = {
	frames: Array<{
		filename: String,
		frame: {
			x: Int,
			y: Int,
			w: Int,
			h: Int
		},
		rotated: Bool,
		trimmed: Bool,
		spriteSourceSize: {
			x: Int,
			y: Int,
			w: Int,
			h: Int
		},
		?center: {x: Int, y: Int},
		sourceSize: {w: Int, h: Int},
		duration: Int,
	}>,
	meta: {
		image: String, frameTags: Array<{
			name: String,
			from: Int,
			to: Int,
			direction: String,
			?scale: Null<Int>,
		}>,
	}
}
