package zf.nav;

/**
	Parent class for any node that are statically linked in all 4 directions
	This should not be used directly.
**/
class StaticNavigationNode extends NavigationNode {
	public var left: NavigationNode;
	public var right: NavigationNode;
	public var up: NavigationNode;
	public var down: NavigationNode;

	override public function dispose() {
		super.dispose();
		this.left = null;
		this.right = null;
		this.up = null;
		this.down = null;
	}

	public function link(node: NavigationNode, direction: Direction, bidirection: Bool = false) {
		switch (direction) {
			case Left:
				this.left = node;
				if (bidirection == true && node is StaticNavigationNode) cast(node, StaticNavigationNode).right = this;
			case Right:
				this.right = node;
				if (bidirection == true && node is StaticNavigationNode) cast(node, StaticNavigationNode).left = this;
			case Up:
				this.up = node;
				if (bidirection == true && node is StaticNavigationNode) cast(node, StaticNavigationNode).down = this;
			case Down:
				this.down = node;
				if (bidirection == true && node is StaticNavigationNode) cast(node, StaticNavigationNode).up = this;
			default:
				Assert.unreachable();
		}
	}

	override function getNodeInDirection(direction: Direction): NavigationNode {
		switch (direction) {
			case Left:
				return this.left;
			case Right:
				return this.right;
			case Up:
				return this.up;
			case Down:
				return this.down;
			default:
		}
		return null;
	}
}
