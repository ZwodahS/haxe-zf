package zf.engine2;

import zf.engine2.messages.MOnComponentAttached;
import zf.engine2.messages.MOnComponentDetached;
import zf.serialise.Serialisable;
import zf.serialise.SerialiseContext;

/**
	@stage:stable
**/
@:autoBuild(zf.macros.Entity.build())
class Entity implements Identifiable implements Serialisable implements EntityContainer {
	// ---- Engine level fields ---- //
	public var factory(default, null): EntityFactory;

	/**
		The world that the entity is contained in.
		This is set by world via registerEntity.

		It is not necessary to add all entities to the world, especially if the entity is part of a composite entity.

		Child class of Entity should provide a world field, which cast __world__ to actual World object
	**/
	public var __world__(default, set): World = null;

	inline function set___world__(w: World): World {
		this.__world__ = w;
		return this.__world__;
	}

	/**
		Provide a reference to the dispatcher.
		This will be null if world is null.

		This can be overriden in the case of composite entity.
	**/
	public var dispatcher(get, never): zf.MessageDispatcher;

	inline function get_dispatcher(): zf.MessageDispatcher {
		return this.__world__?.dispatcher;
	}

	// ---- Entity fields ---- //

	/**
		Allow id to be set. This field is never used outside of resetting the id
		in reset() method.
	**/
	var _forceSetId: Bool = false;

	/**
		The id of the entity. Ideally this should not be set outside of
		- constructor
		- loading

		id -1 is reserved for undefined id, i.e. temporary id.
		World can check for id == -1

		We will allow id to be set if the id is -1. This can be useful from converting a temp entity
		to a permanent entity.
	**/
	public var id(default, set): Int = -1;

	inline public function set_id(id: Int): Int {
		// we will only allow id to be set if the id is -1
		if (this._forceSetId != true && this.id != -1) {
			zf.Logger.warn("Setting id of enttiy when it is not -1.");
			return this.id;
		}
		return this.id = id;
	}

	inline public function identifier(): String {
		return 'entity:${id}';
	}

	/**
		A string represeting what type of entity this is.
		This should be same as the id of the entity factory
	**/
	public var typeId(get, never): String;

	inline public function get_typeId(): String {
		return this.factory == null ? null : this.factory.typeId;
	}

	/**
		Constructor
	**/
	function new(id: Int = -1) {
		this.id = id;
		this.__components__ = [];
	}

	// ---- Components ---- //
	var __components__: Map<String, Component>;

	/**
		No default components at the moment.

		All components should look something like this

		public var renderComponent(default, set): RenderComponent;
		public function set_renderComponent(rc: RenderComponent): RenderComponent {
			final prev = this.renderComponent;
			this.renderComponent = rc;
			this.renderComponent.entity = this;
			onComponentChanged(prev, this.renderComponent);
			return this.renderComponent;
		}
	**/
	/**
		Trigger onComponentChanged when component are add or removed
	**/
	public function onComponentChanged(prev: Component, next: Component) {
		if (prev != null) {
			prev.__entity__ = null;
			this.__components__.remove(prev.typeId);
		}
		if (next != null) {
			next.__entity__ = this;
			this.__components__.set(next.typeId, next);
		}
	}

	inline public function getComponent<T: Component>(typeId: String): T {
		return cast this.__components__.get(typeId);
	}

	// ---- Dispose method ---- //

	/**
		For cleanup. Removing entity from world does not dispose the entity.
		Only dispose entity when it confirmed that it will not be used.

		Disposing will remove all components and no events will be fired.
	**/
	public function dispose() {
		// dispose all components
		for (component in this.__components__) component.dispose();

		// unregister the entity from the world
		if (this.__world__ != null) this.__world__.unregisterEntity(this);

		// reset the entity back to default state
		this.__components__.clear();

		this._forceSetId = true;
		this.id = -1;
		this._forceSetId = false;

		this.factory = null;
	}

	// ---- Methods to be override ---- //

	public function toString(): String {
		return '[Entity/${this.typeId}:${this.id}]';
	}

	// ---- Event handling ---- //
	public function onStateChanged() {
		for (component in this.__components__) component.onStateChanged();
	}

	public function toStruct(context: SerialiseContext): Dynamic {
		return this.factory.toStruct(context, this);
	}

	public function loadStruct(context: SerialiseContext, data: Dynamic) {
		return this.factory.loadStruct(context, this, data);
	}

	public function collectEntities(entities: Entities<zf.engine2.Entity>) {
		entities.add(this);
		for (component in this.__components__) {
			if (component is EntityContainer) cast(component, EntityContainer).collectEntities(entities);
		}
	}
}

/**
	Mon 13:29:50 15 Jul 2024
	Update this to implements
	Serialisable, Identifiable, EntityContainer.
	Moved a lot of variables from template to here

	Sun 17:13:09 11 Aug 2024
	Remove onComponentAttached/onComponentDetached message. I really don't think this is necessary anymore.
	I never like handling logic via if an entity gained/lost component.
	That should always be a separate logic

	I am wondering if entity needs to know about world that it is contained in.
	For now we will keep it in, since I may need to dispatch messages to render the entity.
**/
