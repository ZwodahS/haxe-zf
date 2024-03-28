package zf.input;

typedef NodeLink = {
	public var id: String;
	public var ?up: String;
	public var ?down: String;
	public var ?left: String;
	public var ?right: String;
}

/**
	@stage:unstable
**/
class PadInputNavMap {
	public var current: PadInputNavNode;

	public var navNodes: Map<String, PadInputNavNode>;

	public function new() {
		this.current = null;
		this.navNodes = [];
	}

	public function selectNode(id: String = null, node: PadInputNavNode = null) {
		trace(id, node == null ? 'null' : node.id);
		if (node == null && id != null) node = this.navNodes.get(id);
		if (node == null) return;

		if (this.current != null) {
			this.current.ui.isOver = false;
		}
		this.current = node;
		if (this.current != null) {
			this.current.ui.isOver = true;
		}
	}

	public function addNode(node: PadInputNavNode): PadInputNavNode {
		this.navNodes.set(node.id, node);
		return node;
	}

	public function linkNodes(linkMap: Array<NodeLink>) {
		for (link in linkMap) {
			final node = this.navNodes.get(link.id);
			if (node == null) continue;
			if (link.up != null) node.up = this.navNodes.get(link.up);
			if (link.down != null) node.down = this.navNodes.get(link.down);
			if (link.left != null) node.left = this.navNodes.get(link.left);
			if (link.right != null) node.right = this.navNodes.get(link.right);
		}
	}

	public function onLeft() {
		if (this.current != null && this.current.left != null) selectNode(this.current.left);
	}

	public function onRight() {
		if (this.current != null && this.current.right != null) selectNode(this.current.right);
	}

	public function onUp() {
		if (this.current != null && this.current.up != null) selectNode(this.current.up);
	}

	public function onDown() {
		if (this.current != null && this.current.down != null) selectNode(this.current.down);
	}
}
