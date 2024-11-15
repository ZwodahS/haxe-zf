package zf.ren.ext.tbr;

/**
	Stored the rendered level
**/
class RenderedLevel {
	/**
		Store the level this is rendering
	**/
	public var level: zf.ren.core.Level;

	public var mainLayers: h2d.Layers;

	public var layers: Map<String, h2d.Layers>;

	public function new(level: Level) {
		this.mainLayers = new h2d.Layers();
		this.level = level;
		this.layers = [];
	}

	public function add(id: String, l: h2d.Layers, index: Int) {
		this.mainLayers.add(l, index);
		this.layers.set(id, l);
	}

	inline public function get(id: String): h2d.Layers {
		return this.layers.get(id);
	}

	inline public function exists(id: String): Bool {
		return this.layers.exists(id);
	}

	public function remove() {
		this.mainLayers.removeChildren();
		this.mainLayers.remove();
	}
}
