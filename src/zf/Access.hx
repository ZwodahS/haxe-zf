package zf;

import haxe.DynamicAccess;

/**
	Allow wrapping of different type of data object and provide generic functions to access properties.

	Currently supported:

	- anon struct via haxe.DynamicAccess
	- xml

	methods are implemented on a need basis
**/
class Access {
	var x: Xml;
	var d: DynamicAccess<Dynamic>;

	function new(?xml: Xml, ?struct: Dynamic) {
		if (xml != null) {
			this.x = xml;
			this.get = this.x.get;
		} else if (struct != null) {
			this.d = struct;
			this.get = this.d.get;
		}
	}

	dynamic public function get(name: String): Dynamic {
		throw new zf.exceptions.NotSupported();
	}

	public function getInt(name: String): Null<Int> {
		final raw: Dynamic = this.get(name);
		if (raw == null) return null;
		if (Std.isOfType(raw, Int)) return cast(raw, Int);
		if (Std.isOfType(raw, String)) return Std.parseInt(cast(raw, String));
		return null;
	}

	public function getString(name: String): String {
		final raw: Dynamic = this.get(name);
		if (raw == null) return null;
		if (Std.isOfType(raw, String)) return cast(raw, String);
		return '${raw}';
	}

	/**
		Returns true if the value is "true", false if the value is "false", null otherwise
	**/
	public function getBool(name: String): Null<Bool> {
		var str = getString(name);
		if (str == null) return null;
		switch (str) {
			case "true":
				return true;
			case "false":
				return false;
			default:
				return null;
		}
	}

	// ---- Factory methods ---- //
	static public function xml(xml: Xml): Access {
		return new Access(xml, null);
	}

	static public function struct(s: Dynamic): Access {
		return new Access(null, s);
	}
}
