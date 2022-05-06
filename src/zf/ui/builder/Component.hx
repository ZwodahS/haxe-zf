package zf.ui.builder;

class Component {
	public var type: String;
	public var builder: Builder;

	public function new(type: String) {
		this.type = type;
	}

	public function makeFromXML(element: Xml): h2d.Object {
		throw new zf.exceptions.NotSupported();
	}

	public function makeFromStruct(struct: Dynamic): h2d.Object {
		throw new zf.exceptions.NotSupported();
	}
}
