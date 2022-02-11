package zf;

import haxe.DynamicAccess;

/**
	wrapped around a struct (likely a Json) and provide safe method for accessing nested values.

	This is similar to DynamicAccess, but provide better accessor.

	1. Provide dot notation to access nested values
	2. Does not error when type does not match. Instead, null will be returned.

	This should ideally be used only for dynamic values that are loaded on runtime as it provide no
	compile time checks.
**/
class Struct {
	var data(default, null): DynamicAccess<Dynamic>;

	public var keySeparator = '.';
	public var useCache: Bool = true;

	var cache: Map<String, Dynamic>;

	public function new(data: Dynamic) {
		this.data = data;
		this.cache = new Map<String, Dynamic>();
	}

	/**
		This is the only unchecked function. Provide a dot notation accessor
	**/
	public function get<T>(key: String): T {
		if (this.useCache) {
			final c = this.cache[key];
			if (c != null) return c;
		}
		final splitKeys = key.split(this.keySeparator);
		final value = getValueByKeys(this.data, splitKeys);
		if (useCache) this.cache[key] = value;
		return value;
	}

	public function getInt(key: String): Null<Int> {
		try {
			final value: Int = get(key);
			return value;
		} catch (e) {
			return null;
		}
	}

	public function getString(key: String): String {
		try {
			final value = get(key);
			if (Std.isOfType(value, String)) return value;
			return null;
		} catch (e) {
			return null;
		}
	}

	public function getFloat(key: String): Null<Float> {
		try {
			final value: Float = get(key);
			return value;
		} catch (e) {
			return null;
		}
	}

	public function getStruct(key: String): Struct {
		try {
			final value: Dynamic = get(key);
			return new Struct(value);
		} catch (e) {
			return null;
		}
	}

	static function getValueByKeys<T>(data: DynamicAccess<Dynamic>, keys: Array<String>, ind: Int = 0): T {
		try {
			if (ind >= keys.length) return null;
			final key = keys[ind];
			final value = data.get(key);
			if (ind == keys.length - 1) {
				return value;
			}
			return getValueByKeys(value, keys, ind + 1);
		} catch (e) {
			return null;
		}
	}
}
