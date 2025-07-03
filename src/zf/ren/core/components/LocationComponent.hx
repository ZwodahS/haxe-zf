package zf.ren.core.components;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
#if !macro @:build(zf.macros.Serialise.build()) #end
#if !macro @:build(zf.macros.Engine2.collectEntities()) #end
class LocationComponent extends zf.engine2.Component implements Serialisable implements EntityContainer {
	public static final ComponentType = "LocationComponent";

	@:serialise @:dispose public var x: Null<Int> = null;
	@:serialise @:dispose public var y: Null<Int> = null;
	@:dispose("set") public var level: Level = null;

	public var tile(get, never): zf.ren.core.Tile;

	public function get_tile(): zf.ren.core.Tile {
		return (this.x == null || this.y == null) ? null : this.level?.getTile(this.x, this.y);
	}

	function new() {
		super();
	}

	// ---- Object pooling Methods ----
	public static function alloc(): LocationComponent {
		final comp = LocationComponent.__alloc__();
		return comp;
	}

	public static function empty(): LocationComponent {
		return alloc();
	}
}
// TODO: Serialise code for location component
/**
	Tue 13:33:40 19 Nov 2024
	Serialise code is not in, we will need to do that for the other parts first
**/
