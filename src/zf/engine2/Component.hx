package zf.engine2;

/**
	@stage:stable

	Generic Component object
**/
class Component implements Disposable {
	public var typeId(get, never): String;

	public function get_typeId()
		return "Component";

	public var __entity__(default, set): Entity;

	inline function set___entity__(e: Entity) {
		this.__entity__ = e;
		onEntityUpdated();
		return this.__entity__;
	}

	/**
		A permanent id for this component.
		This is never saved, just a id for each instance of component created during runtime.
		Disposing does not reset this id.

	**/
	public final id: Int = -1;

	public static var nextId: zf.IntCounter.SimpleIntCounter = new zf.IntCounter.SimpleIntCounter();

	public function new() {
		this.id = Component.nextId.getNextInt();
	}

	public function dispose() {
		this.__entity__ = null;
	}

	public function toString(): String {
		return '{Component:${this.typeId}}';
	}

	public function update(dt: Float) {}

	function onEntityUpdated() {}

	public function onStateChanged() {}
}
