package zf.ds;

import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

typedef IntCapacitySF = {
	public var current: Int;
	public var min: Int;
	public var max: Int;
}

/**
	Store a current int value + max value
**/
class IntCapacity implements Serialisable {
	/**
		Allow current value to go above max or below min

		This is never saved.
	**/
	public var allowOutOfRange: Bool = false;

	public var current(default, set): Int = 0;

	public function set_current(v: Int): Int {
		if (this.allowOutOfRange == false) v = Math.clampI(v, this.min, this.max);
		this.current = v;
		onValueChanged();
		return this.current;
	}

	public var min(default, set): Int = 0;

	public function set_min(v: Int): Int {
		this.min = v;
		if (this.allowOutOfRange == true && this.current < min) this.current = this.min;
		return this.min;
	}

	public var max(default, set): Int = 0;

	public function set_max(v: Int): Int {
		this.max = v;
		if (this.allowOutOfRange == true && this.current > max) this.current = this.max;
		return this.max;
	}

	public function reset() {
		this.min = 0;
		this.max = 0;
		this.current = 0;
	}

	public function new(current: Int = 0, min: Int = 0, max: Int = 0, allowOutOfRange: Bool = false) {
		this.allowOutOfRange = allowOutOfRange;
		this.max = max;
		this.min = min;
		this.current = current;
	}

	/**
		Convert to struct
		@return the struct representing the object
	**/
	public function toStruct(context: SerialiseContext): Dynamic {
		final sf: IntCapacitySF = {
			min: this.min,
			max: this.max,
			current: this.current,
		};
		return sf;
	}

	/**
		Load from struct.
		@return the object itself to allow for chaining
	**/
	public function loadStruct(context: SerialiseContext, data: Dynamic): IntCapacity {
		final sf: IntCapacitySF = data;

		this.min = sf.min;
		this.max = sf.max;
		this.current = sf.current;

		return this;
	}

	dynamic public function onValueChanged() {}

	public static function empty(): IntCapacity {
		return new IntCapacity();
	}
}
