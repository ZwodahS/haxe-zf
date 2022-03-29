package zf.tui.templates;

using zf.h2d.ObjectExtensions;

typedef HorizontalFlowLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var items: Array<TemplateConf>;

	/**
		x spacing between each object
	**/
	public var ?spacing: Int;
}

/**
	Provide a template for h2d.Flow
**/
class HorizontalFlowLayout extends Template {
	public function new() {
		super("flow:horizontal");
	}

	override public function make(c: Dynamic): h2d.Object {
		final conf: HorizontalFlowLayoutConf = c;

		var spacing: Int = 0;
		if (conf.spacing != null) spacing = conf.spacing;

		final flow = new h2d.Flow();
		flow.layout = Horizontal;
		flow.horizontalSpacing = spacing;
		flow.verticalAlign = Middle;

		for (item in conf.items) {
			final c = this.factory.createObject(item);
			flow.addChild(c);
		}
		return flow;
	}
}
