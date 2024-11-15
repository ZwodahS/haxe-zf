package zf.ren.ext.components;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
#if !macro @:build(zf.macros.Serialise.build()) #end
class HealthComponent extends zf.engine2.Component implements Serialisable {
	public static final ComponentType = "HealthComponent";

	@:serialise @:dispose public var max: Int = 1;
	@:serialise @:dispose public var current: Int = 1;

	function new() {
		super();
	}

	// ---- Object pooling Methods ----
	public static function alloc(max: Int, current: Int): HealthComponent {
		final comp = HealthComponent.__alloc__();

		comp.max = max;
		comp.current = current;

		return comp;
	}

	public static function empty(): HealthComponent {
		return alloc(1, 1);
	}
}
