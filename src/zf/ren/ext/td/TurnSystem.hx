package zf.ren.ext.td;

import zf.ds.List;
import zf.ren.core.messages.MOnActionCompleted;
import zf.ren.ext.messages.MOnEntityActiveTurn;
import zf.ren.ext.messages.MOnEntityTurnStart;
import zf.ren.ext.messages.MOnEntityTurnEnd;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class TurnSystemEntity {
	@:dispose("set") public var e: Entity = null;
	@:dispose("set") public var tc: TurnComponent = null;

	function new() {}

	public static function alloc(e: Entity, tc: TurnComponent): TurnSystemEntity {
		final object = TurnSystemEntity.__alloc__();

		object.e = e;
		object.tc = tc;

		return object;
	}
}

/**
	Mon 17:55:10 27 Jan 2025
	Unlike tu.TurnSystem, I (can't/don't have to) use a circular linked list here.
	The list need to be re-ordered when entity's timeunit changes.

	Instead, we will use a List instead.
	The list will also be kept ordered, and when timeunit is changed, the order need to be updated.
**/
class TurnQueue {
	var list: List<TurnSystemEntity>;
	var map: Map<Int, ListNode<TurnSystemEntity>>;

	public var activeEntity(get, never): Entity;

	public function get_activeEntity(): Entity {
		return this.current == null ? null : this.current.e;
	}

	public var current(get, never): TurnSystemEntity;

	inline public function get_current(): TurnSystemEntity {
		return this.list.first();
	}

	public function new() {
		this.list = new List<TurnSystemEntity>();
		this.map = new Map<Int, ListNode<TurnSystemEntity>>();
	}

	public function registerEntity(e: Entity, tc: TurnComponent) {
		if (map.exists(e.id)) return;
		final node = insert(TurnSystemEntity.alloc(e, tc));
		this.map[e.id] = node;
	}

	public function insert(e: TurnSystemEntity): ListNode<TurnSystemEntity> {
		if (this.list.length == 0) {
			return this.list.add(e);
		}

		// find the node to insert into.
		// we will always insert after the last node that have the same timeunit
		var f = null;
		for (n in this.list.iterateNode()) {
			if (n.item.tc.timeunit > e.tc.timeunit) {
				f = n;
				break;
			}
		}

		var node: ListNode<TurnSystemEntity> = null;
		if (f == null) {
			if (this.list.length != 0) {
				node = this.list.add(e);
			} else {
				node = this.list.push(e);
			}
		} else {
			node = f.insertBefore(e);
		}

		return node;
	}

	public function unregisterEntity(e: Entity) {
		if (!map.exists(e.id)) return;

		final node = map[e.id];
		this.map.remove(e.id);
		node.item.dispose();
		node.remove();
	}

	public function advance() {
		final amount = this.current.tc.timeunit;
		for (n in this.list) {
			n.tc.timeunit -= amount;
		}
	}

	public function shiftCurrent() {
		if (this.list.length == 0) return;

		shiftNode(this.list.head);
	}

	// on entity updated, call this
	public function shiftEntity(e: Entity) {
		if (map.exists(e.id) == false) return;

		final node = map[e.id];
		shiftNode(node);
	}

	function shiftNode(n: ListNode<TurnSystemEntity>) {
		final te = n.item;
		n.remove();
		final n = this.insert(te);
		this.map[te.e.id] = n;
	}

	/**
		Add the queue position into the turn component.

		the index is only updated when this method is called, and this method is only called when
		the world is saving.
	**/
	public function updateQueuePosition() {
		var ind = 0;
		for (n in this.list) {
			final tc = TurnComponent.get(n.e);
			Assert.assert(tc != null, {typeId: n.e.typeId});
			tc.queuePosition = ind++;
		}
	}

	public function loadQueuePosition() {
		final newList = [];
		for (n in this.list) newList.push(n);

		newList.sort((e1, e2) -> {
			return zf.Compare.int(zf.Compare.Ascending, e1.tc.queuePosition, e2.tc.queuePosition);
		});
		this.list.clear();

		for (n in newList) this.list.add(n);
	}
}

/**
	Time Delay Turn System

	Entities are given a time delay, i.e. how many more time need to pass before it can perform action.

	Each entity will have their own TurnComponent, which also define how much delay after each action.

	This uses ActionResult.

	The follow keys will be use in ActionResult.
	"delay" - This adds on additional delay to current delay
	"overrideDelay" - This overrides the delay of the default delay of the entity.

	@see tu/TurnSystem for alternative
**/
#if !macro @:build(zf.macros.Messages.build()) #end
class TurnSystem extends zf.engine2.System {
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

	public function new(blockedByAnimator: Bool = true) {
		super();
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

		tc.endTurn = result.getValue("endTurn") ?? true;
	}

	override public function reset() {
		this.actualActiveEntity = null;
		this.entitiesTakenTurn.clear();
		this.pause = false;
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
		tc.endTurn = false;
	}

	function unregisterEntity(entity: Entity) {
		this.queue.unregisterEntity(entity);
		if (this.actualActiveEntity == entity) this.actualActiveEntity = null;
	}

	public function delayEntity(e: Entity, amt: Int) {
		final tc = TurnComponent.get(e);
		if (tc == null) return false;
		tc.timeunit += amt;
		/**
			Tue 13:26:59 28 Jan 2025
			If the entity is the current entity, we don't want to update the queue or shit will break
		**/
		if (e != this.activeEntity) this.queue.shiftEntity(e);
		return true;
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
			current.tc.endTurn = false;
			current.tc.timeunit += current.tc.delay;
			current.tc.tookAction = false;
			final entity = current.e;
			// move the queue
			this.queue.shiftCurrent();
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
			// if the current entity is null, and the first entity timeunit is not 0, we will subtract
			// every entity's timeunit by the first entity timeunit.
			if (this.actualActiveEntity == null && this.queue.current.tc.timeunit != 0) this.queue.advance();
			// if the current entity is null, we treat the queue current as the new current and fire the event.
			if (this.actualActiveEntity == null) {
				this.actualActiveEntity = this.queue.current.e;

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
			if (this.queue.current == null || this.actualActiveEntity != this.queue.current.e) {
				// we should fire the entity turn end here as well
				this.dispatcher.dispatch(MOnEntityTurnEnd.alloc(this.actualActiveEntity)).dispose();
				// we also need to set the actualActiveEntity to null and restart the loop
				this.actualActiveEntity = null;
				continue;
			}
			// this is the normal flow. Current actualActiveEntity == this.queue.current
			final current = this.queue.current;
			if (!current.tc.endTurn) {
				// if entity took action but did not end turn, we send a ActiveTurn again.
				if (current.tc.tookAction) {
					current.tc.tookAction = false;
					this.dispatcher.dispatch(MOnEntityActiveTurn.alloc(current.e, true)).dispose();
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
			if (entitiesTakenTurn[current.e.id] != null) break;
			// cache the entity that have taken turn
			this.entitiesTakenTurn[current.e.id] = current.e;
		}
	}

	override public function preSave() {
		this.queue.updateQueuePosition();
	}

	override public function onLoad() {
		this.queue.loadQueuePosition();
		// prevent the activeTurnEvent from firing when loading.
		// that increases the turn counter.
		this.actualActiveEntity = this.queue.activeEntity;
	}
}
