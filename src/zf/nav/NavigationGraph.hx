package zf.nav;

/**
	Create a NavigationGraph to navigate between different ui elements.

	# Motivation
	Often we need to navigate between elements on screen via directional keys.
	Although this is mainly for controller support, it is not necessary limited to controller.

	# Objects
	- NavigationNode is the main class for all navigation. See NavigationNode.hx for more information
	- StaticNavigationNode provide static navigation for when the object positions are fixed.
		This can be used in menu when elements are never added or removed.
		This should not be used directly. Instead subclass it or use existing subclass
	- StaticNavigationGroup
		Create a group to contains nodes.
		When a node is not linked to another node, the parent navigation will be used.
		The group provide 4 additional field to define which node to select when entering from
		the 4 different directions.
		To have a more flexible way of handling which node to return to, create a specialised class

	Non-core sublcasses are in ext/
	- NavigationUIElementNode
		Wrap around any UIElement, i.e. buttons etc and proxy the state change to "toggled"
		flag and wrap activate to call _onClick.
		This works for most buttons etc, and if more specialised function is needed, then other classes
		are probably better

	# How to use

	1. Most menuscreen or static menu can be solved by just using StaticNavigationGroup and NavigationUIElementNode.
	If that is not enough, the rest can be solved using NavigationNode.alloc and just providing the few methods.

	2. Sometimes we will have elements that we don't want to create nodes on start up.
	For example, in a traditional roguelike, we may want to use controller to navigate between tiles.
	If the map is too big, creating nodes for everything can be tricky.
	3. Sometimes number of elements changes, and we can't really fixed the navigation.

	For 2 and 3, this can be solved by sub-classing NavigationNode directly.
**/
class NavigationGraph {
	/**
		Store the current node.
		This will be null when nothing is currently selected, i.e. the navigation is not active.
	**/
	public var currentNode(default, null): NavigationNode;

	/**
		Store the default node.
		This is the default node that is activated when the navigation starts.
	**/
	public var defaultNode: NavigationNode;

	/**
		A main navigation group
	**/
	var nodes: Array<NavigationNode>;

	public function new() {
		this.nodes = [];
	}

	/**
		Main function for navigation.
		This will call onExit and onEnter on the various nodes and return the current node.

		If the navigation fail, the selection will remain at the current node.
		If currentNode is null, navigation will fail.
	**/
	public function navigate(direction: Direction): NavigationNode {
		if (this.currentNode == null) return null;

		final node = this.currentNode.navigate(direction);
		if (node != null) {
			this.currentNode.onExit();
			this.currentNode = node;
			this.currentNode.onEnter();
		}

		return this.currentNode;
	}

	/**
		Add a node to the navigation map for tracking.

		It is not necessary to add every node that is created for tracking.
		Only the top level group / navigation needs to be added here.
	**/
	public function add(node: NavigationNode) {
		Assert.assert(this.nodes.contains(node) == false);
		this.nodes.push(node);
	}

	/**
		Select the default node.

		This method can be used to start the navigation or reset the navigation to the default node.
	**/
	public function selectDefault() {
		if (this.currentNode != null) this.currentNode.onExit();
		this.currentNode = this.defaultNode.getNodeFromDirection(null, null);
		this.currentNode.onEnter();
	}

	/**
		Remove all selection

		This effectively exists the navigation
	**/
	public function selectNone() {
		if (this.currentNode != null) this.currentNode.onExit();
		this.currentNode = null;
	}

	public function dispose() {
		for (n in this.nodes) n.dispose();
	}
}
