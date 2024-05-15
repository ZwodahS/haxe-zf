package zf.ui;

import zf.ds.ArrayMap;

@:structInit
class NavigationNode implements Identifiable {
	public var id: String;

	public var x: Int; // store the x position to move to when navigating to this node
	public var y: Int; // store the y position to move to when navigating to this node

	public var bounds: h2d.col.Bounds; // store the bounds

	public var left: String;
	public var right: String;
	public var up: String;
	public var down: String;

	public function identifier(): String {
		return this.id;
	}

	public function new(id: String, bounds: h2d.col.Bounds, x: Int, y: Int) {
		this.id = id;
		this.bounds = bounds;
		this.x = x;
		this.y = y;
	}

	public function toString() {
		return this.id;
	}
}

/**
	@stage:unstable

	Store a navigation map

	Wed 13:26:28 15 May 2024
	Currently used by Crop Rotation to handle controller input.
**/
class NavigationMap {
	public var nodes: ArrayMap<NavigationNode>;

	public var previousNode: String = null;

	var pt: h2d.col.Point;

	public function new() {
		this.nodes = new ArrayMap<NavigationNode>();
		this.pt = new h2d.col.Point(0, 0);
	}

	public function addNode(node: NavigationNode): NavigationNode {
		this.nodes.push(node);
		return node;
	}

	public function getNode(nId: String): NavigationNode {
		return this.nodes.get(nId);
	}

	/**
		Provide a quick way to link the node
	**/
	public function linkNode(source: String, target: String, direction: zf.Direction, bidirectional: Bool = false) {
		final s = getNode(source);
		final t = getNode(target);
		if (s == null || t == null) return;
		switch (direction) {
			case Left:
				s.left = t.id;
				if (bidirectional == true) t.right = s.id;
			case Right:
				s.right = t.id;
				if (bidirectional == true) t.left = s.id;
			case Up:
				s.up = t.id;
				if (bidirectional == true) t.down = s.id;
			case Down:
				s.down = t.id;
				if (bidirectional == true) t.up = s.id;
			default:
		}
	}

	public function findClosest(x: Float, y: Float): {node: NavigationNode, inBound: Bool} {
		var bounds = null;
		final pt = new h2d.col.Point(x, y);
		var distance: Float = 999999;
		var closest: NavigationNode = null;

		for (node in this.nodes) {
			final d = node.bounds.distanceSq(pt);
			if (d == 0) return {node: node, inBound: true};
			if (d < distance) {
				distance = d;
				closest = node;
			}
		}

		return {node: closest, inBound: false};
	}

	public function navigate(x: Float, y: Float, direction: zf.Direction): NavigationNode {
		pt.x = x;
		pt.y = y;
		var node: NavigationNode = null;
		if (this.previousNode != null) {
			final n = this.getNode(this.previousNode);
			if (n != null && n.bounds.contains(pt) == true) node = n;
		}

		if (node == null) {
			final r = findClosest(x, y);
			if (r.inBound == false) return r.node;
			node = r.node;
		}

		if (node == null) return null;

		final next = switch (direction) {
			case Left: node.left == null ? node : this.getNode(node.left);
			case Right: node.right == null ? node : this.getNode(node.right);
			case Up: node.up == null ? node : this.getNode(node.up);
			case Down: node.down == null ? node : this.getNode(node.down);
			default: node;
		}

		return next;
	}
}
