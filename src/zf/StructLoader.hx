package zf;

import haxe.io.Path;

using StringTools;

using zf.ds.ArrayExtensions;

import zf.exceptions.StructInvalidMerge;
import zf.exceptions.StructRecursiveLoad;

import haxe.DynamicAccess;

/**
	# Motivation
	When building game, most of the time we will need to have some type of game data be loaded from json.
	Eventually when that happen, we will create a very big file.
	Splitting the files into pieces means we will need to know where each piece of data was.
	i.e. file1.valueX vs file2.valueX

	The motivation is then to be able to merge them into one giant file in code after loading them,
	and be able to access them as tho they are one giant config file.

	The added benefit of this is modding. The values of the original files don't have to be changed
	when we want to just modify a certain values via a mod. By having a merge order, we can then
	let the later json override the value in the earlier json, similar to inheritance in OOP.

	Because of this, we will need to reserve certain key and also set up some structure.
	We will use "$" as the keyword prefix.

	## 1. Comments
	Because this essentially a subset declarative programming via data, we will definitely
	need some type of comments.

	Rule 1: any key that starts with "//" will be ignored and will not be loaded.

	## 2. Load
	We some times need to load a key from another file. To achieve this, we will use the "$load" key.

	Rule 2: $load will load a list of file and create the struct.

	Example:
	{
		"tree": {
			"$load": ["tree.json"]
		}
	}

	There will be a few rules regarding this.

	1. If a dictionary contains the "$load", all other key are ignored

	We may eventually need to override the values that are loaded, but that can be done with loading 2 files,
	the original file, followed by the file containing the values to be overriden.

	2. the earlier files' value will be partially replaced by the ones in the later files.

	If the first files have 10 keys, and the second files have 2 new keys with 4 overlapping keys,
	the new data will contains 12 keys, with the 4 overlapping keys' values coming from the second file.
	If the key is a dictionary, then it will recursively replace the values and not the whole struct.

	3. Key of different types
	If 2 keys is of different type, it will be replaced if they are both primitive.
	If one of them is a struct, and the other is a primitive, then an error will occur.

	@todo Fri 14:09:09 18 Mar 2022
	we might eventually need something that remove all the keys in the parent class,
	but we will leave it for another day.

	You can also load files within another files

	Example

	File1
	{
		"tree": {
			"$load": ["tree.json"]
		}
	}

	tree.json
	{
		"leaves": {
			"$load": ["leaves.json"],
		},
		"name": "tree"
	}

	There may also be a chance for recursive loading because of this. So any recursive load will result in
	an exception.

	# Usage
	var struct: zf.Struct = new StructLoader().load(path);
**/
class StructLoader {
	public var loaded: Map<String, Dynamic>;

	public function new() {
		this.loaded = new Map<String, Dynamic>();
	}

	public function loadStruct(path: String): Struct {
		return new Struct(loadPath(path, []));
	}

	function loadPath(path: String, context: Array<String>): Dynamic {
		// convert the path to absolute path
		if (context.length != 0 && path.startsWith("./")) {
			path = Path.normalize(Path.join([Path.directory(context.item(-1)), path]));
		}
		if (this.loaded[path] != null) return this.loaded[path];
		// check for recursive load
		if (context.indexOf(path) != -1) throw new StructRecursiveLoad(path);
		// create a new context
		final newContext = [for (c in context) c];
		newContext.push(path);
		// load data from path
		final string = loadFile(path);
		// parse the data
		final data: DynamicAccess<Dynamic> = haxe.Json.parse(string);

		function parse(data: DynamicAccess<Dynamic>, key: String) {
			if (key.startsWith("//")) {
				data.remove(key);
				return;
			}
			final value: Dynamic = data.get(key);
			// for non-object we are done
			if (Type.typeof(value) != TObject) return;
			final dy: DynamicAccess<Dynamic> = value;
			// check if there is a $load key. if exists, we ignore everything else
			if (dy.exists("$load")) {
				// for each key in $load, we will need to then merge them
				final mergePath: Array<String> = dy.get("$load");
				// prepare the object to replace
				final obj: Dynamic = {};
				for (p in mergePath) {
					final mData = loadPath(p, newContext);
					mergeDynamic(obj, mData);
				}
				// replace
				data.set(key, obj);
			} else {
				for (k in dy.keys()) {
					parse(dy, k);
				}
			}
		}
		// we wrap the object around a key
		final d: Dynamic = {data: data}
		parse(d, "data");
		return d.data;
	}

	public static function mergeDynamic(d1: Dynamic, d2: Dynamic) {
		var da1: DynamicAccess<Dynamic> = d1;
		var da2: DynamicAccess<Dynamic> = d2;

		for (key => value2 in da2) {
			// if the key does not exist, we will just set it
			if (da1.exists(key) == false) {
				// if it is object, we will do a full copy
				if (Type.typeof(value2) == TObject) {
					da1.set(key, Reflect.copy(value2));
				} else {
					da1.set(key, value2);
				}
				continue;
			}
			final value1 = da1.get(key);
			if (Type.typeof(value1) == TObject && Type.typeof(value2) == TObject) {
				mergeDynamic(value1, value2);
				continue;
			} else if (Type.typeof(value1) == TObject || Type.typeof(value2) == TObject) {
				throw new StructInvalidMerge("Attempting to load primitive into object");
			} else { // both are technically primitive
				da1.set(key, value2);
			}
		}
	}

	/**
		Load text from a path.
		can be replaced with other method if we don't want to load from Res
	**/
	dynamic public function loadFile(path: String): String {
		try {
			final file = hxd.Res.load(path);
			final text = file.toText();
			return text;
		} catch (e) {
			throw new ResourceLoadException(path, e);
		}
	}
}
