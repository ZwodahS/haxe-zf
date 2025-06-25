package zf.nav;

/**
	Parent class for all navigation node
**/
class NavigationNode implements Disposable {
	public var parent: NavigationNode;

	// give this node a name for toString
	public var name: String = null;

	function new() {}

	public function dispose() {
		this.parent = null;
		this.name = null;
	}

	/**
		Get the node that this node goes to
		If it get to nowhere, return null.
		Do not return parent's navigation

		@param direction the direction to move to
	**/
	public function getNodeInDirection(direction: Direction): NavigationNode {
		return null;
	}

	/**
		Get the node when this node is entered from currentNode + direction

		This usually return itself, except for when the node is a group of nodes.
		In that case, it will return the relevant child from that direction.
	**/
	public function getNodeFromDirection(curr: NavigationNode, direction: Direction): NavigationNode {
		return this;
	}

	/**
		Core navigation method.
		Changing this is usually unnecessary.

		Navigate and return the node in this direction.
		If the current node does not navigate, the parent navigation will be returned.
		return null if nothing to navigate to.

		@param direction the direction to navigate to
		@param currentNode the actual currentNode that is navigation from, default to this if not provided.
	**/
	public function navigate(direction: Direction, currentNode: NavigationNode = null): NavigationNode {
		if (currentNode == null) currentNode = this;

		final node = getNodeInDirection(direction);
		if (node != null) {
			final n = node.getNodeFromDirection(this, direction.opposite);
			if (n != null) return n;

			// this handles the case where a dynamic nav group returns null, and we need to navigate that group
			final n = node.navigate(direction);
			if (n != null) return n;
		}

		if (this.parent != null) {
			final parentNode = this.parent.navigate(direction, currentNode);
			return parentNode;
		}

		return null;
	}

	/**
		This is called when the node is navigated away.
		This is always called before onEnter of the new node (if any)
	**/
	public function onExit() {}

	/**
		This is called when the node is navigated into.
		Note that this will never be called for parent nodes.
		This is always called after onExit of the previous node (if any)
	**/
	public function onEnter() {}

	/**
		What to do when the button is pressed.

		Tue 13:45:40 27 May 2025
		I am not sure if I need this method here.
		If so, I might have to extend this to accepting keycode / padcode.
	**/
	@:unstable public function activate() {}

	/**
		Create a node by just providing the various functions as argument.
	**/
	public static function alloc(_getNodeInDirection: Direction->NavigationNode = null,
			_getNodeFromDirection: (NavigationNode, Direction) -> NavigationNode = null, _onEnter: Void->Void = null,
			_onExit: Void->Void = null, _onActivate: Void->Void = null): DynamicNavigationElement {
		return DynamicNavigationElement.alloc(_getNodeInDirection, _getNodeFromDirection, _onEnter, _onExit,
			_onActivate);
	}

	public function toString() {
		return this.name ?? "Unknown Navigation Node";
	}
}

/**
	Private class for alloc method of NavigationNode.
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
private class DynamicNavigationElement extends NavigationNode {
	@:dispose public var _getNodeInDirection: Direction->NavigationNode = null;
	@:dispose public var _getNodeFromDirection: (NavigationNode, Direction) -> NavigationNode = null;
	@:dispose public var _onEnter: Void->Void = null;
	@:dispose public var _onExit: Void->Void = null;
	@:dispose public var _onActivate: Void->Void = null;

	@:dispose public var disposeOnExit: Bool = false;

	public static function alloc(_getNodeInDirection: Direction->NavigationNode = null,
			_getNodeFromDirection: (NavigationNode, Direction) -> NavigationNode = null, _onEnter: Void->Void = null,
			_onExit: Void->Void = null, _onActivate: Void->Void = null): DynamicNavigationElement {
		final node = DynamicNavigationElement.__alloc__();

		node._getNodeInDirection = _getNodeInDirection;
		node._getNodeFromDirection = _getNodeFromDirection;
		node._onEnter = _onEnter;
		node._onExit = _onExit;
		node._onActivate = _onActivate;

		return node;
	}

	override public function getNodeInDirection(direction: Direction): NavigationNode {
		if (this._getNodeInDirection != null) return this._getNodeInDirection(direction);
		return super.getNodeInDirection(direction);
	}

	override public function getNodeFromDirection(node: NavigationNode, direction: Direction): NavigationNode {
		if (this._getNodeFromDirection != null) return this._getNodeFromDirection(node, direction);
		return super.getNodeFromDirection(node, direction);
	}

	override public function onEnter() {
		if (this._onEnter != null) this._onEnter();
	}

	override public function onExit() {
		if (this._onExit != null) this._onExit();
		if (disposeOnExit == true) this.dispose();
	}

	override public function activate() {
		if (this._onActivate != null) this._onActivate();
	}
}
