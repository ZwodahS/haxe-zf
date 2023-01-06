package zf.ui.builder;

/**
	@stage:stable
**/
class ComponentException extends haxe.Exception {
	public var xmlNode: Xml;
	public var structNode: Dynamic;

	public function new() {
		super("Fail to parse Component");
	}

	override public function toString(): String {
		if (this.xmlNode != null) return 'Fail to parse XML element: ${this.xmlNode}';
		if (this.structNode != null) return 'Fail to parse struct: ${this.structNode}';
		return 'Fail to parse Component.';
	}
}
