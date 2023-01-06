package zf.ui.builder;

/**
	@stage:stable
**/
typedef ComponentConf = {
	public var ?id: String; // the unique identifier for this component, aka h2d.Object.name
	public var type: String;
	public var conf: Dynamic;
	public var ?layout: Dynamic;
}
