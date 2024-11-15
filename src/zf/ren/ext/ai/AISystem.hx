package zf.ren.ext.ai;

import zf.ren.ext.messages.MOnEntityActiveTurn;

/**
	Sat 12:04:14 23 Nov 2024
	AISystem is deprecated.
	Handle turns tends to requires very specialised logic, especially when we load it from script.

	It means that "handleTurn" is usually not generalised enough.
**/
#if !macro @:build(zf.macros.Messages.build()) #end
@:deprecated class AISystem extends zf.engine2.System {
	public function new() {
		super();
	}

	override public function init(world: zf.engine2.World) {
		super.init(world);
		setupMessages(world.dispatcher);
	}

	@:handleMessage("MOnEntityActiveTurn", 100)
	function mAITakeTurn(m: MOnEntityActiveTurn) {
		final aic = AIComponent.get(m.entity);
		if (aic == null) return;
		aic.takeTurn(cast this.__world__);
	}
}
