package zf.ui.builder;

class Component {
	public var type: String;

	public function new(type: String) {
		this.type = type;
	}

	public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		throw new zf.exceptions.NotSupported();
	}

	public function makeFromStruct(struct: Dynamic, context: BuilderContext): h2d.Object {
		throw new zf.exceptions.NotSupported();
	}
}
