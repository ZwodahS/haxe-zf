package zf.input;

/**
	@stage:unstable
**/
class PadInputNavNode {
	/**
		The 4 node to go to after press the directions
	**/
	public var left: PadInputNavNode = null;

	public var right: PadInputNavNode = null;
	public var up: PadInputNavNode = null;
	public var down: PadInputNavNode = null;

	/**
		The parent node if any.
		The idea is that if there is a parent, any unhandled nav will be handled by the parent.
	**/
	public var parent: PadInputNavNode = null;

	/**
		Any ui element attached to it.
	**/
	public var ui: UIElement;

	/**
		The id representing the node
	**/
	public var id: String;

	public var cursorPosition: Point2f = null;

	public function new(id: String, ui: UIElement = null) {
		this.id = id;
		this.ui = ui;
	}
}
