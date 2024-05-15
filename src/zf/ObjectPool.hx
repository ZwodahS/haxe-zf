package zf;

class ObjectPool<T> {
	var pool: List<T>;

	public var count(get, never): Int;

	inline public function get_count(): Int {
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

		If the pool is already at max capacity, the object is not stored.
	**/
	public function recycle(o: T) {
		if (this.count >= this.maxPoolSize) return;
		this.pool.add(o);
	}

	/**
		Return an instance of the object
	**/
	public function alloc(): T {
		final object = this.pool.length > 0 ? this.pool.pop() : this.makeFunc();
		resetObject(object);
		return object;
	}

	dynamic public function resetObject(o: T) {}
}
/**
	Sun 13:52:11 05 May 2024
	The goal of the macro based object pool is to remove the need for this.
	However, I realised that I needed an object pool for bitmap that is used for animations.
**/
