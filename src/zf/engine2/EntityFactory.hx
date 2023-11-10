package zf.engine2;

import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

/**
	@stage:stable

	A common EntityFactory.

	Each project from templates also comes with a common EntityFactory.
**/
class EntityFactory implements Identifiable {
	public var typeId(default, null): String;

	inline public function identifier(): String {
		return this.typeId;
	}

	public function new(typeId: String) {
		this.typeId = typeId;
	}

	public function toStruct(context: SerialiseContext, entity: Entity): Dynamic {
		final components: DynamicAccess<Dynamic> = {};
		@:privateAccess for (component in entity.__components__) {
			if (Std.isOfType(component, Serialisable) == false) continue;
			final sf = cast(component, Serialisable).toStruct(context);
			components.set(component.typeId, sf);
		}
		final data: EntitySF = {
			id: entity.id,
			typeId: this.typeId,
			components: components,
		};
		if (context != null) {
			context.add(entity);
		}
		return data;
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
