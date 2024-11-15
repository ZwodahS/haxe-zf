package zf.ren.ext.player;

#if !macro @:build(zf.macros.Messages.build()) #end
class PlayerSystem extends zf.engine2.System {
	/**
		Player Entity.

		A Special Entity since it is the one that the player control.
	**/
	public var player(default, set): Entity = null;

	public function set_player(p: Entity): Entity {
		if (this.player == p) return this.player;
		final prev = this.player;
		this.player = p;
		this.dispatcher.dispatch(MOnPlayerSet.alloc(prev, this.player)).dispose();
		return this.player;
	}

	public function new() {
		super();
	}

	override public function init(world: zf.engine2.World) {
		super.init(world);
		setupMessages(world.dispatcher);
	}
}
/**
	Mon 13:48:26 18 Nov 2024
	Previously in ren, this is part of ren.core.World

	However, when moving to zf.ren, I think spliting it out into a separate system seems better
**/
