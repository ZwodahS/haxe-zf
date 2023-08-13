package zf;

class UpdateElements {
	var elements: haxe.ds.List<UpdateElement>;

	public function new() {
		this.elements = new haxe.ds.List<UpdateElement>();
	}

	public function update(dt: Float) {
		for (e in this.elements) e.update(dt);
	}

	public function add(e: UpdateElement) {
		this.elements.add(e);
	}

	public function remove(e: UpdateElement): Bool {
		return this.elements.remove(e);
	}
}
