package zf.engine2;

/**
	@stage:stable
**/
class Iterator<E: Entity> {
	var map: ReadOnlyEntities<E>;
	var keys: Array<Int>;
	var curr: Int;

	function new(map: ReadOnlyEntities<E>, keys: Array<Int>) {
		this.map = map;
		this.keys = keys;
		this.curr = 0;
	}

	public function hasNext(): Bool {
		return curr < keys.length;
	}

	public function next(): Null<E> {
		if (!hasNext()) return null;
		return this.map.get(this.keys[this.curr++]);
	}
}

class KeyValueIterator<E: Entity> {
	var map: ReadOnlyEntities<E>;
	var keys: Array<Int>;
	var curr: Int;

	function new(map: ReadOnlyEntities<E>, keys: Array<Int>) {
		this.map = map;
		this.keys = keys;
		this.curr = 0;
	}

	public function hasNext(): Bool {
		return curr < keys.length;
	}

	public function next(): {key: Int, value: Null<E>} {
		if (!hasNext()) return null;
		var key = this.keys[curr++];
		var value = this.map.get(key);
		return {key: key, value: value};
	}
}

@:access(zf.engine2.Iterator)
@:access(zf.engine2.KeyValueIterator)
class ReadOnlyEntities<E: Entity> {
	var map: Map<Int, E>;

	/**
		Return the number of entities.
	**/
	public var count(default, null): Int;

	/**
		Return the number of entities.

		@see count
	**/
	public var length(get, never): Int;

	inline public function get_length(): Int {
		return this.count;
	}

	function new() {
		this.map = new Map<Int, E>();
		this.count = 0;
	}

	/**
		Find and returns the first entity that returns true

		@param match function E -> Bool
	**/
	public function findEntity(match: E->Bool): E {
		for (e in this.map) {
			if (match(e)) return e;
		}
		return null;
	}

	/**
		Find all entities that match.

		Order is not guaranteed

		@param match function E -> Bool
	**/
	public function findEntities(match: E->Bool): Array<E> {
		var entities: Array<E> = [];
		for (e in this.map) {
			if (match(e)) entities.push(e);
		}
		return entities;
	}

	/**
		Get Entity by id

		@param id entity id
	**/
	public function get(id: Int): E {
		return this.map[id];
	}

	/**
		Check if entity exists

		@param e Entity to check
	**/
	public function exists(e: E): Bool {
		return this.map[e.id] != null;
	}

	/**
		Check if an Entity id exists

		@param id Entity id to check
	**/
	public function idExists(id: Int): Bool {
		return this.map[id] != null;
	}

	public function iterator(): Iterator<E> {
		return new Iterator(this, [for (k in this.map.keys()) k]);
	}

	public function keyValueIterator(): KeyValueIterator<E> {
		return new KeyValueIterator(this, [for (k in this.map.keys()) k]);
	}
}

@:access(zf.engine2.Iterator)
@:access(zf.engine2.KeyValueIterator)
class Entities<E: Entity> extends ReadOnlyEntities<E> implements Identifiable {
	/**
		Allow this to be added as Identifiable
	**/
	public var id: String = "entities";

	public function identifier(): String {
		return this.id;
	}

	public function new() {
		super();
	}

	/**
		Clear this entity map.
		All entities are removed.
	**/
	public function clear() {
		this.map.clear();
		this.count = 0;
	}

	/**
		Make a shallow copy of this entity map.
	**/
	public function copy(): Entities<E> {
		var m = new Entities<E>();
		for (k => e in this.map) m.add(e);
		return m;
	}

	/**
		Add entity to the map

		@param e Entity to add
	**/
	public function add(e: E) {
		if (map[e.id] != null) return;
		this.map[e.id] = e;
		this.count += 1;
	}

	/**
		Remove entity from the map

		@param e Entity to remove
	**/
	public function remove(e: E): Bool {
		if (map[e.id] == null) return false;
		this.map.remove(e.id);
		this.count -= 1;
		return true;
	}

	/**
		Remove entity from the map by entity id

		@param id entity id
	**/
	public function removeById(id: Int): E {
		var e = this.map[id];
		if (e == null) return null;
		this.map.remove(id);
		this.count -= 1;
		return e;
	}

	public function readonly(): ReadOnlyEntities<E> {
		return this;
	}
}
