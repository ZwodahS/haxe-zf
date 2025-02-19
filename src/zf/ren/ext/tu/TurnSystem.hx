package zf.ren.ext.tu;

import zf.ds.CircularLinkedList;
import zf.ren.core.messages.MOnActionCompleted;
import zf.ren.ext.messages.MOnEntityActiveTurn;
import zf.ren.ext.messages.MOnEntityTurnStart;
import zf.ren.ext.messages.MOnEntityTurnEnd;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class TurnSystemEntity {
	@:dispose public var e: Entity = null;
	@:dispose("set") public var tc: TurnComponent = null;

	function new() {}

	public static function alloc(e: Entity, tc: TurnComponent): TurnSystemEntity {
		final object = TurnSystemEntity.__alloc__();

		object.e = e;
		object.tc = tc;

		return object;
	}
}

class TurnQueue extends CircularLinkedList<TurnSystemEntity> {
	var map: Map<Int, CircularLinkedNode<TurnSystemEntity>>;

	public var activeEntity(get, never): Entity;

	public function get_activeEntity(): Entity {
		return this.current == null ? null : this.current.item.e;
	}

	public function new() {
		super();
		this.map = new Map<Int, CircularLinkedNode<TurnSystemEntity>>();
	}

	public function registerEntity(e: Entity, tc: TurnComponent) {
		if (map.exists(e.id)) return;
		final node = super.insertBefore(TurnSystemEntity.alloc(e, tc));
		this.map[e.id] = node;
	}

	public function unregisterEntity(e: Entity) {
		if (!map.exists(e.id)) return;

		final node = map[e.id];
		this.map.remove(e.id);
		node.item.dispose();
		node.remove();
	}
}

/**
	Time Unit Turn System

	Each entity is given a fixed number of time unit each turn.
	Once they finish those time unit, they are moved back to the end of the queue.

	By default, tuPerTurn is set to 1, meaning all entity take 1 action per turn.

	TurnSystem uses ActionResult.
	If TurnSystem is used in the engine, all action should set 2 keys in ActionResult

	"cost" - Int (if not present default to 0)
	"endTurn" - Bool (if not present default to fasle)

	@see td/TurnSystem for alternative
**/
#if !macro @:build(zf.macros.Messages.build()) #end
class TurnSystem extends zf.engine2.System {
	public var tuPerTurn(default, null): Int = 1;

	var queue: TurnQueue;

	public var activeEntity(get, never): Entity;
	public var pause: Bool = false;

	public var world(get, never): zf.ren.core.World;

	inline public function get_world(): zf.ren.core.World {
		return cast this.__world__;
	}

	public inline function get_activeEntity(): Entity {
		return this.queue.activeEntity;
	}

	/**
		if true, turn selection will wait until all animations is completed.
		setting to false may have weird effects if not handled properly.
	**/
	public var blockedByAnimator: Bool = true;

	public function new(timeUnitPerTurn: Int = 1, blockedByAnimator: Bool = true) {
		super();
		this.tuPerTurn = timeUnitPerTurn;
		this.queue = new TurnQueue();
		this.blockedByAnimator = blockedByAnimator;
	}

	override public function init(world: zf.engine2.World) {
		super.init(world);
		setupMessages(world.dispatcher);
	}

	@:handleMessage("MOnActionCompleted", 100)
	function mDispatchNextEntityAction(m: MOnActionCompleted) {
		final entity = m.action.entity;
		final action = m.action;
		final result = m.result;

		if (this.queue.activeEntity != entity) return;

		final tc = TurnComponent.get(entity);
		tc.tookAction = true;

		final endTurn = result.getBool("endTurn") ?? false;
		final cost = result.getInt("cost") ?? 0;

		if (endTurn == true) {
			tc.endTurn = true;
		} else {
			tc.timeunit -= cost;
			if (tc.timeunit <= 0) tc.endTurn = true;
		}
	}

	override public function reset() {
		this.actualActiveEntity = null;
		this.entitiesTakenTurn.clear();
		this.pause = false;
	}

	public function forceEntityTurn(e: Entity) {
		final node = this.queue.findOneNode(function(n) {
			return n.e == e;
		});

		if (node != null) {
			while (this.queue.current.item.e != e)
				this.queue.next();
		}
	}

	override public function onEntityAdded(e: zf.engine2.Entity) {
		final tc = TurnComponent.get(e);
		if (tc == null) return;
		registerEntity(cast e, tc);
	}

	override public function onEntityRemoved(e: zf.engine2.Entity) {
		unregisterEntity(cast e);
	}

	function registerEntity(entity: Entity, tc: TurnComponent) {
		this.queue.registerEntity(entity, tc);
		tc.timeunit = tuPerTurn;
		tc.endTurn = false;
	}

	function unregisterEntity(entity: Entity) {
		this.queue.unregisterEntity(entity);
	}

	var actualActiveEntity: Entity = null;
	var entitiesTakenTurn: Map<Int, Entity> = new Map<Int, Entity>();

	override public function update(dt: Float) {
		/**
			In general, all implementation of TurnSystem need to fire 2 events.

			- MOnEntityTurnStart to inform the start of entity turn
			- MOnEntityTurnEnd to inform that the entity has ended their turn.
			- MOnEntityActiveTurn to inform that it is now the entity's turn.

			The decision to fire these event handles on every update frame.

			There a lot of things that sometimes needs to happen between the messages, so we need to handle them.
			The basic gist of how turn system works is this

			> if no entity is currently active, find the next entity, and fire MOnEntityActiveTurn
			> if there is an entity currently active, check if it ended its turn, and if so, fire MOnEntityTurnEnd

			The part that makes it tricky is how this interacts with any AI System.
			When TurnSystem fires MOnEntityActiveTurn, and if the entity is controlled by an AI,
			it will immediately perform the action, ending the turn if there is no animations.

			When TurnSystem regain control, the state of the queue would have already changed
			and need to be handled.

			One of the biggest problems might be that the active entity might die and be removed from the queue.
			When this happens, the next entity will become the current entity in the queue,
			and if this is not handled properly, the entity might miss a turn, or the game will enter into
			a inconsistent state.

			In additional to that, if entity taking turn does not have animations, e.g. off screen enemy,
			then it is better to simulate them all in a single frame.
		**/

		if (this.pause) return;

		inline function endCurrentEntityTurn() {
			// reset the state of the current entity
			final current = this.queue.current;
			current.item.tc.endTurn = false;
			current.item.tc.timeunit = tuPerTurn;
			current.item.tc.tookAction = false;
			final entity = current.item.e;
			// move the queue
			this.queue.next();
			// set actualActiveEntity to null
			this.actualActiveEntity = null;
			// dispatch the end turn event
			// this dispatch might change the state of the turn queue.
			this.dispatcher.dispatch(MOnEntityTurnEnd.alloc(entity)).dispose();
		}

		// ensure that every frame each entities will only take action once.
		// the loop here is to allow for more than 1 action performed per frame.
		// this is useful for when entity is out of sight and we are not animating.
		this.entitiesTakenTurn.clear();
		while (true) {
			// if the world is animating and we want to block turn from simulating
			// when there is a blocking animator, we don't do anything.
			if (this.blockedByAnimator && this.world.isAnimating) return;
			// when there is 0 item and nothing is current active, we just exit the loop
			if (this.actualActiveEntity == null && this.queue.current == null) return;
			// if the current entity is null, we treat the queue current as the new current and fire the event.
			if (this.actualActiveEntity == null) {
				this.actualActiveEntity = this.queue.current.item.e;

				final disrupted = this.dispatcher.getResult(MOnEntityTurnStart.alloc(this.actualActiveEntity));
				// if the turn is disrupted, we will immediately end the entity turn
				if (disrupted) {
					endCurrentEntityTurn();
					continue;
				}
				this.dispatcher.dispatch(MOnEntityActiveTurn.alloc(this.actualActiveEntity)).dispose();
				// there is no need to break the loop, since the MOnEntityActiveTurn may have ended the entity's turn.
				// this is the case for AI taking their turn that does not involve animation.
			}
			// this case handles when the active entity is removed from the turnqueue as part of performing Action
			// this also handles the case where entityactive finishes and there is nothing in the queue,
			// i.e. the last entity died as part of the action;
			if (this.queue.current == null || this.actualActiveEntity != this.queue.current.item.e) {
				// we should fire the entity turn end here as well
				this.dispatcher.dispatch(MOnEntityTurnEnd.alloc(this.actualActiveEntity)).dispose();
				// we also need to set the actualActiveEntity to null and restart the loop
				this.actualActiveEntity = null;
				continue;
			}
			// this is the normal flow. Current actualActiveEntity == this.queue.current
			final current = this.queue.current;
			if (!current.item.tc.endTurn) {
				// if entity took action but did not end turn, we send a ActiveTurn again.
				if (current.item.tc.tookAction) {
					current.item.tc.tookAction = false;
					this.dispatcher.dispatch(MOnEntityActiveTurn.alloc(current.item.e, true)).dispose();
				}
				// we will return here as the turn is not ended yet
				return;
			}
			// clean up after entity end turn
			endCurrentEntityTurn();
			/**
				peek ahead, if the next entity that is about to take the turn already took a turn in this cycle,
				we exit the loop. This is to give the UI a chance to accept input.
				If we don't handle this, when the player dies, the game might enter a infinite loop when simulating
				enemies movement. This will not be a problem if the movement have animations, but in the case
				where there is no animations, it will be stucked forever.
			**/
			if (current == null) break;
			if (entitiesTakenTurn[current.item.e.id] != null) break;
			// cache the entity that have taken turn
			this.entitiesTakenTurn[current.item.e.id] = current.item.e;
		}
	}
}
