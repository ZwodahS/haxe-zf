package zf;

interface Recyclable {
	/**
		Called first when the object is created and will be used.
	**/
	public function reset(): Void;

	/**
		Called when the object is returned back to the pool.
	**/
	public function recycle(): Void;
}

@:deprecated("Use macro based object pooling instead")
class ObjectPool<T: Recyclable> {
	var pool: List<T>;

	public var count(get, never): Int;

	public function get_count(): Int {
		return this.pool.length;
	}

	/**
		The max number of item to store in the pool.

		Setting this while running do not reduce the current size of the pool.
		This setting only restrict the number of object store in the pool when `recycle` is called.
	**/
	public var maxPoolSize: Int = 300;

	/**
		The function to make the object.
	**/
	var makeFunc: Void->T;

	public function new(makeFunc: Void->T, initialSize: Int = 0, maxPoolSize: Int = 300) {
		this.makeFunc = makeFunc;
		this.pool = new List<T>();
		this.maxPoolSize = maxPoolSize;
		for (_ in 0...initialSize) {
			this.pool.add(makeFunc());
		}
	}

	/**
		Return an instance of the object to the pool.

		If the pool is already at max capacity, `recycle` will be called and the object will be discarded.
	**/
	public function recycle(o: T) {
		o.recycle();
		if (this.count >= this.maxPoolSize) return;
		o.recycle();
	}

	public function make(): T {
		final object = this.pool.length > 0 ? this.pool.pop() : this.makeFunc();
		object.reset();
		return object;
	}
}
