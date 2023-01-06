package zf;

/**
	@stage:stable
**/
class WrappedValue<T> {
	public var value(default, set): T;

	var listeners: Map<Int, (T, T) -> Void>;
	var listenerCounter: Int = 0;

	public function new(defaultValue: T) {
		this.listeners = new Map<Int, (T, T) -> Void>();
		this.value = defaultValue;
	}

	public function set_value(value: T): T {
		var oldValue = this.value;
		this.value = value;
		for (l in this.listeners) {
			l(oldValue, this.value);
		}
		return this.value;
	}

	public function listen(func: (T, T) -> Void): Int {
		var id = listenerCounter++;
		this.listeners[id] = func;
		return id;
	}

	public function removeListener(id: Int) {
		this.listeners.remove(id);
	}
}
