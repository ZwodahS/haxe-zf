package common.ecs;

class Iterator<E: Entity> {
    var map: EntityMap<E>;
    var keys: Array<Int>;
    var curr: Int;

    function new(map: EntityMap<E>, keys: Array<Int>) {
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
    var map: EntityMap<E>;
    var keys: Array<Int>;
    var curr: Int;

    function new(map: EntityMap<E>, keys: Array<Int>) {
        this.map = map;
        this.keys = keys;
        this.curr = 0;
    }

    public function hasNext(): Bool {
        return curr < keys.length;
    }

    public function next(): {key: Int, value: Null<E>} {
        if (!hasNext()) return null;
        var key = curr;
        var value = this.map.get(this.keys[this.curr++]);
        return {key: key, value: value};
    }
}

@:access(common.ecs.Iterator)
@:access(common.ecs.KeyValueIterator)
class EntityMap<E: Entity> {
    var map: Map<Int, E>;

    public var count(default, null): Int;

    public function new() {
        this.map = new Map<Int, E>();
        this.count = 0;
    }

    public function clear() {
        this.map.clear();
        this.count = 0;
    }

    public function copy(): EntityMap<E> {
        var m = new EntityMap<E>();
        for (k => e in this.map) m.add(e);
        return m;
    }

    public function add(e: E) {
        if (map[e.id] != null) return;
        this.map[e.id] = e;
        this.count += 1;
    }

    public function remove(e: E): Bool {
        if (map[e.id] == null) return false;
        this.map.remove(e.id);
        this.count -= 1;
        return true;
    }

    public function removeById(id: Int): E {
        var e = this.map[id];
        if (e == null) return null;
        this.map.remove(id);
        this.count -= 1;
        return e;
    }

    public function get(id: Int): E {
        return this.map[id];
    }

    public function exists(e: E): Bool {
        return this.map[e.id] != null;
    }

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
