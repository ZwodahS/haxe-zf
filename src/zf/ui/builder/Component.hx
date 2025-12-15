package zf.ui.builder;

/**
	A component that can be built by Builder.
**/
class Component {
	public var type: String;

	public function new(type: String) {
		this.type = type;
	}

	public function build(element: Xml, context: BuilderContext): ComponentObject {
		throw new zf.exceptions.NotSupported();
	}
}
