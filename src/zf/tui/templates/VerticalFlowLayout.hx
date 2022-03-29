package zf.tui.templates;

using zf.h2d.ObjectExtensions;

private typedef LayoutConf = {
	public var ?paddingTop: Int;
}

typedef VerticalFlowLayoutConf = {
	/**
		All item in this horizontal
	**/
	public var items: Array<TemplateConf>;

	/**
		y spacing between each object
	**/
	public var ?spacing: Int;
}

/**
	Provide a template for h2d.Flow
**/
class VerticalFlowLayout extends Template {
	public function new() {
		super("flow:vertical");
	}

	override public function make(c: Dynamic): h2d.Object {
		final conf: VerticalFlowLayoutConf = c;

		var spacing: Int = 0;
		if (conf.spacing != null) spacing = conf.spacing;

		final flow = new h2d.Flow();
		flow.layout = Vertical;
		flow.verticalSpacing = spacing;
		flow.horizontalAlign = Left;

		for (item in conf.items) {
			final c = this.factory.createObject(item);
			flow.addChild(c);
			if (item.layout != null) {
				final layout: LayoutConf = item.layout;
				if (layout.paddingTop != null) {
					final properties = flow.getProperties(c);
					properties.paddingTop = layout.paddingTop;
				}
			}
		}

		return flow;
	}
}
