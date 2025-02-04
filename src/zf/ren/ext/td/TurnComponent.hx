package zf.ren.ext.td;

import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
#if !macro @:build(zf.macros.Serialise.build()) #end
#if !macro @:build(zf.macros.Engine2.collectEntities()) #end
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
		Used internally by TurnSystem
	**/
	@:dispoe public var tookAction: Bool = false;

	function new() {
		super();
	}

	// ---- Object pooling Methods ----
	public static function alloc(): TurnComponent {
		final comp = TurnComponent.__alloc__();
		return comp;
	}

	public static function empty(): TurnComponent {
		return alloc();
	}

	override public function toString(): String {
		return '{c:TurnComponent: ${this.timeunit}|${this.endTurn}}';
	}
}
