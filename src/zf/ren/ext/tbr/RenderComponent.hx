package zf.ren.ext.tbr;

class RenderComponent extends zf.engine2.Component {
	public static final ComponentType = "tbr.RenderComponent";

	/**
		The layer to render at
	**/
	public var layer: String = "entity";

	/**
		The object to render
	**/
	public var ro: h2d.Object = null;

	public var priority: Int = 0;

	function new() {
		super();
	}

	override public function dispose() {
		super.dispose();
		this.layer = "entity";
		if (this.ro != null) {
			this.ro.remove();
			this.ro = null;
		}
		this.priority = 0;
	}
}
