package zf.ui.builder.components;

typedef GridLayoutConf = {}

/**
	@stage:stable

	attributes:

	size: Point2i (row / column) - default [1, 1]
		- in XML, use sizeX, sizeY
		- in Struct, use size: [x, y]
	gridSize: Point2i (size of each grid) - default [0, 0]
		- in XML, use gridSizeX, gridSizeY
		- in Struct, use gridSize: [x, y]
	spacing: Point2i - default [0, 0]
		- in XML, use spacingX, spacingY
		- in Struct use spacing: [x, y]

	This returns FixedGridLayout
**/
class GridLayout extends zf.ui.builder.Component {
	public function new() {
		super("layout-grid");
	}

	override public function makeFromStruct(s: Dynamic, context: BuilderContext): zf.ui.layout.FixedGridLayout {
		final conf = zf.Access.struct(s);
		var size: Point2i = conf.get("size");
		var gridSize: Point2i = conf.get("gridSize");
		var spacing: Point2i = conf.get("spacing");
		return make(conf, context, size, gridSize, spacing);
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): zf.ui.layout.FixedGridLayout {
		final conf = zf.Access.xml(element);
		var size: Point2i = [1, 1];
		var gridSize: Point2i = [0, 0];
		var spacing: Point2i = [0, 0];
		if (conf.getInt("sizeX") != null) size.x = conf.getInt("sizeX");
		if (conf.getInt("sizeY") != null) size.y = conf.getInt("sizeY");

		if (conf.getInt("gridSizeX") != null) gridSize.x = conf.getInt("gridSizeX");
		if (conf.getInt("gridSizeY") != null) gridSize.y = conf.getInt("gridSizeY");

		if (conf.getInt("spacingX") != null) spacing.x = conf.getInt("spacingX");
		if (conf.getInt("spacingY") != null) spacing.y = conf.getInt("spacingY");
		return make(conf, context, size, gridSize, spacing);
	}

	function make(conf: zf.Access, context: BuilderContext, size: Point2i, gridSize: Point2i,
			spacing: Point2i): zf.ui.layout.FixedGridLayout {
		if (size == null) size = [1, 1];
		if (gridSize == null) gridSize = [0, 0];
		if (spacing == null) spacing = [0, 0];

		final component = new zf.ui.layout.FixedGridLayout(size, gridSize);
		component.spacing = spacing;

		if (conf.getString("name") != null) component.name = conf.getString("name");

		return component;
	}
}
