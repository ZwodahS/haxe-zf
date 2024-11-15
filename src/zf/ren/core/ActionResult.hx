package zf.ren.core;

/**
	A generic action result that can be used to store any value

	Fri 14:26:56 15 Nov 2024
	Previously in ren.core, we need to extend action result.
	This time, we will just store all metadata in this instead.
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class ActionResult implements Disposable {
	var values: Map<String, Dynamic>;

	function new() {
		this.values = [];
	}

	function reset() {
		this.values.clear();
	}

	public function setValue(key: String, value: Dynamic) {
		this.values.set(key, value);
	}

	public function getValue(key: String): Dynamic {
		return this.values.get(key);
	}

	public function getInt(key: String): Null<Int> {
		final v = this.values.get(key);
		return (v != null && v is Int) ? cast v : null;
	}

	public function getString(key: String): String {
		final v = this.values.get(key);
		return (v != null && v is String) ? cast v : null;
	}

	public function getBool(key: String): Null<Bool> {
		final v = this.values.get(key);
		return (v != null && v is Bool) ? cast v : null;
	}
}
