package zf;

import haxe.DynamicAccess;

/**
	@stage:stable

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
			this._get = this.x.get;
		} else if (struct != null) {
			this.d = struct;
			this._get = this.d.get;
		}
	}

	public function get<T>(name: String): Null<T> {
		return _get(name);
	}

	dynamic function _get(name: String): Dynamic {
		throw new zf.exceptions.NotSupported();
	}

	public function getInt(name: String, defaultValue: Null<Int> = null): Null<Int> {
		final raw: Dynamic = this.get(name);
		if (raw == null) return defaultValue;
		if (Std.isOfType(raw, Int)) return cast(raw, Int);
		if (Std.isOfType(raw, String)) return Std.parseInt(cast(raw, String));
		return defaultValue;
	}

	public function getString(name: String, defaultValue: String = null): String {
		final raw: Dynamic = this.get(name);
		if (raw == null) return defaultValue;
		if (Std.isOfType(raw, String)) return cast(raw, String);
		return '${raw}';
	}

	/**
		Returns true if the value is "true", false if the value is "false", null otherwise
	**/
	public function getBool(name: String, defaultValue: Null<Bool> = null): Null<Bool> {
		final rawValue = _get(name);
		if (Std.isOfType(rawValue, Bool)) return cast(rawValue, Bool);
		final strValue = getString(name);
		if (strValue == null) return defaultValue;
		switch (strValue) {
			case "true":
				return true;
			case "false":
				return false;
			default:
				return defaultValue;
		}
	}

	public function getArray<T>(name: String, defaultValue: Array<T> = null): Array<T> {
		final rawValue = _get(name);
		if (rawValue == null) return defaultValue;
		try {
			final arr: Array<T> = cast rawValue;
			return arr;
		} catch (e) {
			return defaultValue;
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
