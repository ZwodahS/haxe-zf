package zf.ecs;

import zf.ecs.messages.ComponentRemoved;
import zf.ecs.messages.ComponentAttached;

class DynamicEntity extends zf.ecs.Entity {
	var components: Map<String, Component>;

	public function new() {
		super();
		this.components = new Map<String, Component>();
	}

	public function getComponent(type: String): Component {
		return this.components[type];
	}

	public function attachComponent(component: Component) {
		removeComponentByType(component.type);
		this.components[component.type] = component;
		if (this.world != null) this.world.dispatcher.dispatch(new ComponentAttached(this, component));
	}

	public function removeComponentByType(type: String): Component {
		if (this.components[type] == null) return null;
		var component = this.components[type];
		if (this.world != null) this.world.dispatcher.dispatch(new ComponentRemoved(this, component));
		this.components.remove(type);
		return component;
	}

	public function removeComponent(component: Component): Component {
		var toRemove = this.components[component.type];
		if (toRemove == null) return null;
		if (toRemove != component) return null;
		return removeComponentByType(component.type);
	}

	public function hasComponent(type: String): Bool {
		return this.components[type] != null;
	}
}
