package zf.ui.builder.components;

typedef GridLayoutConf = {}

/**
	Create a FixedGridLayout

	# Attributes:
	- size[X|Y] (Int) (default 1,1)
	- gridSize[X|Y] (Int) (default 0,0)
	- spacing[X|Y] (Int) (default 0,0)

**/
class GridLayout extends Component {
	public function new() {
		super("layout-grid");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = Access.xml(element);
		final size: Point2i = [1, 1];
		final gridSize: Point2i = [0, 0];
		final spacing: Point2i = [0, 0];

		if (conf.getInt("sizeX") != null) size.x = conf.getInt("sizeX");
		if (conf.getInt("sizeY") != null) size.y = conf.getInt("sizeY");

		if (conf.getInt("gridSizeX") != null) gridSize.x = conf.getInt("gridSizeX");
		if (conf.getInt("gridSizeY") != null) gridSize.y = conf.getInt("gridSizeY");

		if (conf.getInt("spacingX") != null) spacing.x = conf.getInt("spacingX");
		if (conf.getInt("spacingY") != null) spacing.y = conf.getInt("spacingY");

		final component = new zf.ui.layout.FixedGridLayout(size, gridSize);
		component.spacing = spacing;

		return {object: component};
	}
}
