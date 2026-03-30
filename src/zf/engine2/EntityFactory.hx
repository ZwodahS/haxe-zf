package zf.engine2;

import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

/**
	A common EntityFactory.

	Each project from templates also comes with a common EntityFactory.
**/
class EntityFactory implements Identifiable {
	public var typeId(default, null): String;

	public var typeTags: Map<String, Bool>;

	inline public function identifier(): String {
		return this.typeId;
	}

	public function new(typeId: String, typeTags: Array<String> = null) {
		this.typeId = typeId;
		this.typeTags = [];
		if (typeTags != null) {
			for (t in typeTags) addTag(t);
		}
	}

	public function toStruct(context: SerialiseContext, entity: Entity, struct: Dynamic = null): Dynamic {
		if (struct == null) struct = {};
		final components: DynamicAccess<Dynamic> = {};
		@:privateAccess for (component in entity.__components__) {
			if (Std.isOfType(component, Serialisable) == false) continue;
			final sf = cast(component, Serialisable).toStruct(context);
			components.set(component.typeId, sf);
		}
		struct.id = entity.id;
		struct.typeId = this.typeId;
		struct.components = components;

		if (context != null) {
			context.add(entity);
		}

		return struct;
	}

	public function isTypeTag(tag: String): Bool {
		return this.typeTags.get(tag) == true;
	}

	public function addTag(tag: String) {
		this.typeTags[tag] = true;
	}

	public function removeTag(tag: String) {
		this.typeTags.remove(tag);
	}

	/**
		Make factory
	**/
	public function make(id: Int, worldState: WorldState, conf: Dynamic = null): Entity {
		throw new zf.exceptions.NotImplemented();
	}

	/**
		Copy the entity. This should set the id to -1
	**/
	public function copy(entity: Entity, worldState: WorldState): Entity {
		throw new zf.exceptions.NotImplemented();
	}

	/**
		Load the data into the entity
	**/
	public function loadStruct(context: SerialiseContext, entity: Entity, data: Dynamic): Entity {
		final sf: EntitySF = cast data;
		final components: DynamicAccess<Dynamic> = sf.components;
		@:privateAccess for (component in entity.__components__) {
			if (component != null && Std.isOfType(component, Serialisable) == false) continue;
			final componentSF = components.get(component.typeId);
			cast(component, Serialisable).loadStruct(context, componentSF);
		}
		return entity;
	}

	public function loadEmpty(context: SerialiseContext, data: Dynamic): Entity {
		throw new zf.exceptions.NotImplemented();
	}
}

/**
	Fri 12:54:46 12 Jul 2024
	Created the common EntityFactory in zf.
**/
