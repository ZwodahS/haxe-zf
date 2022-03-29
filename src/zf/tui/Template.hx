package zf.tui;

class Template {
	public var type: String;
	public var factory: Factory;

	public function new(type: String) {
		this.type = type;
	}

	public function make(conf: Dynamic): h2d.Object {
		return null;
	}
}
