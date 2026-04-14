package zf.ds;

/**
	Wrap Set around Map
**/
import zf.serialise.SerialiseContext;

interface ISet<T> extends zf.serialise.Serialisable {
	public function add(v: T): Bool;
	public function exists(v: T): Bool;
	public function remove(v: T): Null<T>;
	public function clear(): Void;
}

@:transitive
@:multiType(@:followWithAbstracts T)
abstract Set<T>(ISet<T>) {
	public function new();

	@:to static inline function toStringSet<T: String>(v: ISet<T>): StringSet {
		return new StringSet();
	}

	public inline function add(v: T): Bool {
		return this.add(v);
	}

	public inline function remove(v: T): Null<T> {
		return this.remove(v);
	}

	public inline function exists(v: T): Bool {
		return this.exists(v);
	}

	public inline function clear() {
		return this.clear();
	}

	public inline function toStruct(context: SerialiseContext, struct: Dynamic = null): Dynamic {
		return this.toStruct(context, struct);
	}

	public inline function loadStruct(context: SerialiseContext, struct: Dynamic): Set<T> {
		return this.loadStruct(context, struct);
	}
}

class StringSet implements ISet<String> implements zf.serialise.Serialisable {
	public var _ds: Map<String, Bool>;
	public function new() {
		this._ds = [];
	}

	public function add(v: String): Bool {
		if (_ds.exists(v) == true) return false;
		_ds[v] = true;
		return true;
	}

	public function exists(v: String): Bool {
		return _ds.exists(v) == true;
	}

	public function remove(v: String): Null<String> {
		if (_ds.exists(v) == false) return null;
		_ds.remove(v);
		return v;
	}

	public function clear(): Void {
		this._ds.clear();
	}

	public function toStruct(context: SerialiseContext, struct: Dynamic = null): Dynamic {
		if (struct == null) struct = [];
		final sorted = [];
		for (k => _ in this._ds) sorted.push(k);
		sorted.sort(Compare.string.bind(true, Compare.Ascending));
		for (s in sorted) struct.push(s);
		return struct;
	}

	public function loadStruct(context: SerialiseContext, struct: Dynamic): StringSet {
		for (s in (struct: Array<String>)) {
			this._ds[s] = true;
		}
		return this;
	}

	public function toString() {
		return 'StringSet: ${[for (s => _ in this._ds) s]}';
	}
}
/**
	Tue 15:20:12 14 Apr 2026

	Implement as needed. I think we will need an Identifiable version later.
	Reason for this is to allow Set to be serialise different from Map, even tho the underlying structure
	is the same.
**/
