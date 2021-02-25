package zf.ecs;

/**
	Generic Entity object.
**/
class Entity {
	/**
		The world that the entity is in.

		This is set by world.addEntity, and should not be set manually from child class
	**/
	public var world(default, null): World;

	public var id(default, null): Int; // id is only set during construction

	public static var IdCounter: zf.IntCounter = new zf.IntCounter.SimpleIntCounter();

	public function new(id: Null<Int> = null) {
		if (id == null) {
			this.id = IdCounter.getNextInt();
		} else {
			this.id = id;
		}
	}

	public function destroy() {}

	public function toString(): String {
		return '(Entity:${this.id})';
	}
}
