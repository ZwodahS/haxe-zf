package zf.ds;

using zf.ds.ArrayExtensions;

class Iterator<E: Identifiable> {
	var ds: ReadOnlyArrayMap<E>;

	var curr: Int;

	public function new(ds: ReadOnlyArrayMap<E>) {
		this.ds = ds;
		this.curr = 0;
	}

	public function hasNext(): Bool {
		return curr < this.ds.length;
	}

	public function next(): Null<E> {
		if (hasNext() == false) return null;
		return this.ds.get(this.curr++);
	}
}

class KeyValueIterator<E: Identifiable> {
	var ds: ReadOnlyArrayMap<E>;
	var keys: Array<String>;
	var curr: Int;

	public function new(ds: ReadOnlyArrayMap<E>) {
		this.ds = ds;
		this.curr = 0;
		@:privateAccess this.keys = [for (k in this.ds.itemsById.keys()) k];
	}

	public function hasNext(): Bool {
		return curr < keys.length;
	}

	public function next(): {key: String, value: Null<E>} {
		if (hasNext() == false) return null;
		final key = this.keys[curr++];
		final value = this.ds.get(key);
		return {key: key, value: value};
	}
}

/**
	@:stable

	  # Motivation
	More often than not, we will need to store objects in both a list and access them by id.
	To do that, we usually create both an array and also an array.
	Managing them become a hassle, so might as well create a data structure for it.

	To handle this, the object must be identifiable
**/
class ReadOnlyArrayMap<E: Identifiable> {
	var itemsByIndex: Array<E>;
	var itemsById: Map<String, E>;

	/**
		The number of item in the array
	**/
	public var length(get, never): Int;

	public function get_length(): Int {
		return this.itemsByIndex.length;
	}

	public function toArray(copy: Bool = true) {
		if (copy == false) return this.itemsByIndex;
		return [for (i in this.itemsByIndex) i];
	}

	public function new() {
		this.itemsByIndex = [];
		this.itemsById = [];
	}

	/**
		Get object

		@param index the position of the item in the array
		@param id the id of the entity.

		If neither of the param is provide, null is returned.
	**/
	public function get(index: Null<Int> = null, id: String = null): E {
		if (index != null) {
			return this.itemsByIndex.item(index);
		} else if (id != null) {
			return this.itemsById.get(id);
		}
		return null;
	}

	/**
		Make a shadow copy of arraymap
	**/
	public function clone(): ArrayMap<E> {
		final arr = new ArrayMap<E>();
		for (item in this.itemsByIndex) {
			arr.push(item);
		}
		return arr;
	}

	public function copyToArray(): Array<E> {
		final items: Array<E> = [];
		for (c in this.itemsByIndex) {
			items.push(c);
		}
		return items;
	}

	public function contains(object: E): Bool {
		return get(object.identifier()) == object;
	}

	// ---- Proxy List operators ---- //
	inline public function indexOf(e: E, ?fromIndex: Int): Int {
		return this.itemsByIndex.indexOf(e, fromIndex);
	}

	inline public function lastIndexOf(e: E, ?fromIndex: Int): Int {
		return this.itemsByIndex.lastIndexOf(e, fromIndex);
	}

	// ---- Proxy Map operators ---- //
	inline public function exists(id: String): Bool {
		return this.itemsById.exists(id);
	}

	// ---- Iterators ---- //
	public function iterator(): Iterator<E> {
		return new Iterator<E>(this);
	}

	public function keyValueIterator(): KeyValueIterator<E> {
		return new KeyValueIterator<E>(this);
	}

	// ---- List operations ---- //
	inline public function filter(f: E->Bool): Array<E> {
		return this.itemsByIndex.filter(f);
	}
}

class ArrayMap<E: Identifiable> extends ReadOnlyArrayMap<E> {
	/**
		Push object. Mirror the push method of array

		If an entity exists with the same identifier, the existing entity will be removed first.
		If the entity already exists, it may be rearranged.

		@param object Entity to add
		@param rearrange if true, the list will be rearranged if the existing object is in the array
		@return the existing object with the same id, null otherwise. If existing is the same as object,
						then null is returned.
	**/
	public function push(object: E, rearrange: Bool = false): E {
		var existing = this.get(object.identifier());
		if (existing == object) {
			// if rearrange is false, then we will just return.
			if (rearrange == false) return null;
			remove(object);
			existing = null; // set it to null since there is nothing to return
		}
		this.itemsByIndex.push(object);
		this.itemsById[object.identifier()] = object;
		return existing;
	}

	/**
		Remove object

		@param object the object to remove
		@return the removed object, null if the object is not removed.
	**/
	public function remove(object: E): E {
		final existing = this.itemsById[object.identifier()];
		if (existing == null || existing != object) return null;
		return _removeObject(object);
	}

	/**
		Remove object by id

		@param id the id to remove
		@return the removed object, null if nothing is removed.
	**/
	public function removeById(id: String): E {
		final existing = this.itemsById[id];
		if (existing == null) return null;
		return _removeObject(existing);
	}

	/**
		Do not call this directly.
		This will not check for anything
	**/
	function _removeObject(object: E) {
		this.itemsById.remove(object.identifier());
		this.itemsByIndex.remove(object);
		return object;
	}

	public function readonly(): ReadOnlyArrayMap<E> {
		return this;
	}

	public function sort(f: (v1: E, v2: E) -> Int) {
		this.itemsByIndex.sort(f);
	}

	public function clear() {
		this.itemsById.clear();
		this.itemsByIndex.clear();
	}

	/**
		Create a ArrayMap from an Array.

		If there are duplicated object in the array, the earlier one will take priority.
		If there are duplicated id, the later one will take priority

		@param arr the array of object
		@return ArrayMap containing all the items with duplicate removed
	**/
	public static function fromArray<E: Identifiable>(arr: Array<E>) {
		final am = new ArrayMap<E>();
		for (object in arr) am.push(object);
		return am;
	}

	public function randomItem(r: hxd.Rand): E {
		return this.itemsByIndex.randomItem(r);
	}
}
