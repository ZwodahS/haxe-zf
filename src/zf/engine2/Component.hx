package zf.engine2;

/**
	Generic Component object
**/
class Component {
	public var typeId(get, never): String;

	inline function get_typeId() return "Component";

	public var __entity__: Entity;

	public function dispose() {}

	public function toString(): String {
		return '{Component:${this.typeId}}';
	}

	public function toStruct(): Dynamic {
		return {};
	}

	public function loadStruct(conf: Dynamic) {}
}
