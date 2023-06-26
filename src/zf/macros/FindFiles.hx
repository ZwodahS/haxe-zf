package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class FindFiles {
	public var regex: EReg;
	public var rootDir: String;

	public var fieldName: String = "files";

	public function new(rootDir: String, regex: String, fieldName: String = "files") {
		this.rootDir = rootDir;
		this.regex = new EReg(regex, "");
		this.fieldName = fieldName;
	}

	public function addFields() {
		var fields = Context.getBuildFields();
		var filenames: Array<String> = [];

		function readFiles(path: String) {
			for (file in sys.FileSystem.readDirectory(path)) {
				final fullPath = '${path}/${file}';
				if (sys.FileSystem.isDirectory(fullPath)) {
					readFiles(fullPath);
				} else if (this.regex.match(fullPath) == true) {
					filenames.push(fullPath);
				}
			}
		}
		readFiles(this.rootDir);

		fields.push({
			name: this.fieldName,
			access: [AStatic, APublic],
			kind: FVar(macro : Array<String>, macro $v{filenames}),
			pos: Context.currentPos(),
		});
		return fields;
	}

	public static function find(rootDir: String, regex: String, fieldName: String = "files") {
		return new FindFiles(rootDir, regex, fieldName).addFields();
	}
}
#end
