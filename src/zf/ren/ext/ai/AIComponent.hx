package zf.ren.ext.ai;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
@:deprecated class AIComponent extends zf.engine2.Component {
	public static final ComponentType = "AIComponent";

	@:dispose public var handleTurn: (Entity, World) -> Void = null;

	function new() {
		super();
	}

	// ---- Object pooling Methods ----
	public static function alloc(handleTurn: (Entity, World) -> Void): AIComponent {
		final comp = AIComponent.__alloc__();

		comp.handleTurn = handleTurn;

		return comp;
	}

	public function takeTurn(world: World) {
		if (this.handleTurn != null) this.handleTurn(this.__entity__, world);
	}
}
