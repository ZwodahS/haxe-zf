package zf.engine2;

/**
	@stage:stable

	Generic Component object
**/
class Component {
	public var typeId(get, never): String;

	public function get_typeId()
		return "Component";

	public var __entity__(default, set): Entity;

	inline function set___entity__(e: Entity) {
		this.__entity__ = e;
		onEntityUpdated();
		return this.__entity__;
	}

	public function dispose() {}

	public function toString(): String {
		return '{Component:${this.typeId}}';
	}

	public function update(dt: Float) {}

	function onEntityUpdated() {}

	public function onStateChanged() {}
}
