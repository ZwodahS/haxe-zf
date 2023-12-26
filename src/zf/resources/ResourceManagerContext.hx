package zf.resources;

class ResourceManagerContext {
	var manager: ResourceManager;

	public function new(manager: ResourceManager) {
		this.manager = manager;
	}

	public function load(path: String) {
		this.manager.load(path);
	}
}
