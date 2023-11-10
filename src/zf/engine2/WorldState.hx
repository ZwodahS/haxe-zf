package zf.engine2;

import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

typedef WorldStateSF = {
	public var ?intCounter: Int;
	public var ?entities: Array<Dynamic>;
}

class WorldState implements Serialisable implements Identifiable implements EntityContainer {
	public var r: hxd.Rand;

	/**
		Int counter for id generation
	**/
	var intCounter: zf.IntCounter.SimpleIntCounter;

	public var nextId(get, never): Int;

	public function get_nextId(): Int {
		return this.intCounter.getNextInt();
	}

	public var entities(get, never): Entities<zf.engine2.Entity>;

	public function get_entities(): Entities<zf.engine2.Entity> {
		final entities = new Entities<zf.engine2.Entity>();
		collectEntities(entities);
		return entities;
	}

	/**
		identifier
	**/
	public function identifier() {
		return "WorldState";
	}

	public function new(seed: Int = 0) {
		this.intCounter = new zf.IntCounter.SimpleIntCounter();
		this.r = new hxd.Rand(seed);
	}

	public function collectEntities(entities: Entities<Entity>) {}

	public function toStruct(context: SerialiseContext): Dynamic {
		final entities: Entities<zf.engine2.Entity> = this.entities;
		context.add(entities);

		collectEntities(entities);

		final stateSF: WorldStateSF = {};

		// store the id generators
		@:privateAccess stateSF.intCounter = this.intCounter.counter;

		// collect all the entities before this is called
		final entitiesSF = [for (entity in entities) cast(entity, Entity).toStruct(context)];
		stateSF.entities = entitiesSF;

		// TODO: save/load seed/r

		return stateSF;
	}

	public function loadStruct(context: SerialiseContext, data: Dynamic): WorldState {
		final stateSF: WorldStateSF = cast data;
		final entitiesSF: Array<Dynamic> = stateSF.entities;
		final entities: Entities<Entity> = new Entities<Entity>();
		context.add(entities);

		for (sf in entitiesSF) {
			final factory = getEntityFactory(sf.typeId);
			if (factory == null) {
				Logger.warn('Fail to load entity, Type: ${sf.typeId}, Id: ${sf.id}');
				continue;
			}
			final entity = factory.loadEmpty(context, sf);
			entities.add(entity);
		}

		// for each of the entities, now we can load the entity proper
		for (sf in entitiesSF) {
			final entity = entities.get(sf.id);
			if (entity == null) continue;
			entity.loadStruct(context, sf);
		}

		@:privateAccess this.intCounter.counter = stateSF.intCounter;
		return this;
	}

	public function getEntityFactory(typeId: String): EntityFactory {
		return null;
	}
}
