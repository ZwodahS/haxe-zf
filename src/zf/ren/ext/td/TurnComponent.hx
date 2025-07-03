package zf.ren.ext.td;

import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
#if !macro @:build(zf.macros.Serialise.build()) #end
#if !macro @:build(zf.macros.Engine2.collectEntities()) #end
@:allow(zf.ren.ext.td.TurnSystem)
class TurnComponent extends zf.engine2.Component implements Serialisable implements EntityContainer {
	public static final ComponentType = "TurnComponent";

	/**
		All entity will have time unit.
		This is set by the TurnSystem.
	**/
	@:dispose @:serialise public var timeunit: Int = 0;

	/**
		The delay after each action
	**/
	@:dispose @:serialise public var delay: Int = 1;

	/**
		Used internally by TurnSystem
	**/
	@:dispose @:serialise public var endTurn: Bool = false;

	/**
		Used internally by TurnSystem to track if the entity has taken action this cycle
	**/
	@:dispose var tookAction: Bool = false;

	/**
		Used internally by TurnSystem to track the entity position in the queue
		This is only recorded when preSave is called.
		This is used on load to populate the queue back to the state
	**/
	@:dispose @:serialise var queuePosition: Int = -1;

	// ---- Object pooling Methods ----
	public static function empty(): TurnComponent {
		return alloc();
	}

	override public function toString(): String {
		return '{c:TurnComponent: ${this.timeunit}|${this.endTurn}}';
	}
}
