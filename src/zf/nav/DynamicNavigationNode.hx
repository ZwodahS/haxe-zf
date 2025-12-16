package zf.nav;

/**
	Create a NavigationNode with everything being dynamic attributes.
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class DynamicNavigationNode extends NavigationNode {
	@:dispose public var _getNodeInDirection: Direction->NavigationNode = null;
	@:dispose public var _getNodeFromDirection: (NavigationNode, Direction) -> NavigationNode = null;
	@:dispose public var _onEnter: Void->Void = null;
	@:dispose public var _onExit: Void->Void = null;
	@:dispose public var _onActivate: Void->Void = null;

	@:dispose public var disposeOnExit: Bool = false;
	@:dispose("all") public var childrens: Array<NavigationNode>;

	public static function alloc(_getNodeInDirection: Direction->NavigationNode = null,
			_getNodeFromDirection: (NavigationNode, Direction) -> NavigationNode = null, _onEnter: Void->Void = null,
			_onExit: Void->Void = null, _onActivate: Void->Void = null): DynamicNavigationNode {
		final node = DynamicNavigationNode.__alloc__();

		node._getNodeInDirection = _getNodeInDirection;
		node._getNodeFromDirection = _getNodeFromDirection;
		node._onEnter = _onEnter;
		node._onExit = _onExit;
		node._onActivate = _onActivate;
		node.childrens = [];

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
