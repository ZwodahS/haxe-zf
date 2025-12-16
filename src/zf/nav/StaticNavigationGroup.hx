package zf.nav;

/**
	A static navigation group.
	Nodes in this group are meant to be linked,
	this group always return the same node when entering from the same direction.

	Assumption
	1. fromLeft/fromRight/fromTop/fromBottom are assumed to be the children of this group.
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class StaticNavigationGroup extends StaticNavigationNode {
	/**
		Add the children managed by this group.
		They will be disposed when the group is disposed.
	**/
	public var children: Array<NavigationNode>;

	@:dispose("set") public var fromLeft: NavigationNode = null;
	@:dispose("set") public var fromRight: NavigationNode = null;
	@:dispose("set") public var fromTop: NavigationNode = null;
	@:dispose("set") public var fromBottom: NavigationNode = null;

	function new() {
		super();
		this.children = [];
	}

	public function add(node: NavigationNode) {
		this.children.push(node);
		node.parent = this;
	}

	override function getNodeFromDirection(curr: NavigationNode, direction: Direction): NavigationNode {
		final node = switch (direction) {
			case Left:
				this.fromLeft ?? this.children.item(0);
			case Right:
				this.fromRight ?? this.children.item(0);
			case Up:
				this.fromTop ?? this.children.item(0);
			case Down:
				this.fromBottom ?? this.children.item(0);
			default:
				/**
					Tue 15:46:52 16 Dec 2025
					Previously this is null. I need this to be a default value when this group is the default node.
					Not sure if this will break anything.
				**/
				this.fromTop;
		}
		return node == null ? null : node.getNodeFromDirection(curr, direction);
	}

	public function reset() {
		for (n in this.children) n.dispose();
		this.children.clear();
	}
}
