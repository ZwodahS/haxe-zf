package zf;

/**
	Generic Object Factory

	The first type is the object that is being created.
	The second type is a template that create the object.

**/
@:deprecated
class Factory<O, T: Template<O>> {
	var templates: Map<String, T>;

	/**
		Create a new Factory
	**/
	public function new() {
		this.templates = new Map<String, T>();
	}

	/**
		Make an object from a template with given name
	**/
	public function make(name: String, r: hxd.Rand): O {
		var template = templates[name];
		if (template == null) return null;
		return template.make(r);
	}

	/**
		Register a template
	**/
	public function register(name: String, template: T) {
		this.templates[name] = template;
	}

	/**
		Unregister a template
	**/
	public function unregister(name: String) {
		this.templates.remove(name);
	}

	public function get(name: String): T {
		return templates[name];
	}
}
