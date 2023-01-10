package zf.engine2;

import zf.engine2.messages.MOnComponentAttached;
import zf.engine2.messages.MOnComponentDetached;

/**
	@stage:unstable
**/
class Entity implements Identifiable {
	// ---- Engine level fields ---- //

	/**
		The world that the entity is contained in.
		This is set by world via registerEntity.

		It is not necessary to add all entities to the world, especially if the entity is part of a composite entity.

		Child class of Entity should provide a world field, which cast __world__ to actual World object

		For Composite entity, get___world__ can be overriden to get it from parent entity.
	**/
	public var __world__(default, set): World;

	function set___world__(w: World): World {
		this.__world__ = w;
		this.onWorldSet();
		return this.__world__;
	}

	/**
		Provide a reference to the dispatcher.
		This will be null if world is null.

		This can be overriden in the case of composite entity.
	**/
	public var dispatcher(get, never): zf.MessageDispatcher;

	function get_dispatcher(): zf.MessageDispatcher {
		return this.__world__ == null ? null : this.__world__.dispatcher;
	}

	// ---- Entity fields ---- //

	/**
		The id of the entity. Ideally this should not be set outside of
		- constructor
		- loading

		id -1 is reserved for undefined id, i.e. temporary id.
		World will check if for id -1 entity during registerEntity

		We will allow id to be set if the id is -1. This can be useful from converting a temp entity
		to a permanent entity.
	**/
	public var id(default, set): Int = -1;

	inline public function set_id(id: Int): Int {
		// we will only allow id to be set if the id is -1
		if (this.id != -1) return this.id;
		return this.id = id;
	}

	public function identifier(): String {
		return 'entity:${id}';
	}

	/**
		A string represeting what type of entity this is.
	**/
	public var typeId(default, null): String;

	/**
		Constructor
	**/
	public function new(id: Int = -1) {
		this.id = id;
		this.__components__ = [];
	}

	// ---- Components ---- //
	var __components__: Array<Component>;

	/**
		No default components at the moment.

		All components should look something like this
	**/
	/**
		public var renderComponent(default, set): RenderComponent;

		public function set_renderComponent(rc: RenderComponent): RenderComponent {
			final prev = this.renderComponent;
			this.renderComponent = rc;
			this.renderComponent.entity = this;
			onComponentChanged(prev, this.renderComponent);
			return this.renderComponent;
		}
	**/
	public function onComponentChanged(prev: Component, next: Component) {
		if (prev != null) {
			prev.__entity__ = null;
			this.__components__.remove(prev);
		}
		if (next != null) {
			next.__entity__ = this;
			this.__components__.push(next);
		}
		if (this.dispatcher != null) {
			if (prev != null) this.dispatcher.dispatch(new MOnComponentDetached(this, prev));
			if (next != null) this.dispatcher.dispatch(new MOnComponentAttached(this, next));
		}
	}

	// ---- Positions for entity ---- //
	var __x__: Float = 0;

	var __y__: Float = 0;

	public var x(get, set): Float;

	public function set_x(x: Float) return this.__x__ = x;

	public function get_x() return __x__;

	public var y(get, set): Float;

	public function set_y(y: Float) return this.__y__ = y;

	public function get_y() return __y__;

	public function setPosition(x: Float, y: Float) {
		this.__x__ = x;
		this.__y__ = y;
	}

	// ---- Rotation ---- //
	var __rotation__: Float = 0;

	public var rotation(get, set): Float;

	public function get_rotation() return this.__rotation__;

	public function set_rotation(r: Float) {
		return this.__rotation__ = r;
	}

	// ---- Dispose method ---- //

	/**
		For cleanup. Removing entity from world does not dispose the entity.
		Only dispose entity when it confirmed that it will not be used.
	**/
	public function dispose() {
		for (component in this.__components__) {
			component.dispose();
		}
	}

	// ---- Methods to be override ---- //

	/**
		The main update method of entity.
	**/
	public function update(dt: Float) {
		for (component in this.__components__) component.update(dt);
	}

	public function toString(): String {
		return '[Entity/${this.typeId}:${this.id}]';
	}

	// ---- Event handling ---- //

	/**
		Handle when world is set to the entity.
	**/
	function onWorldSet() {}
}
