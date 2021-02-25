package zf.ds;

import zf.Assert;

@:allow(zf.ds.CircularLinkedList)
class CircularLinkedNode<T> {
	public var next(default, null): CircularLinkedNode<T>;
	public var prev(default, null): CircularLinkedNode<T>;
	public var item(default, null): T;

	var list: CircularLinkedList<T>;

	public function new(item: T) {
		this.item = item;
	}

	function insertNodeBefore(node: CircularLinkedNode<T>) {
		this.prev.next = node;
		node.prev = this.prev;

		this.prev = node;
		node.next = this;
	}

	function insertNodeAfter(node: CircularLinkedNode<T>) {
		this.next.prev = node;
		node.next = this.next;

		this.next = node;
		node.prev = this;
	}

	public function remove(): Bool {
		if (this.list == null) return false;
		return this.list.removeNode(this);
	}

	public function toString(): String {
		return 'Node: ${this.item}';
	}
}

class CircularLinkedList<T> {
	public var current(default, null): CircularLinkedNode<T>;

	public function new() {}

	public function insertBefore(item: T): CircularLinkedNode<T> {
		var node = new CircularLinkedNode<T>(item);
		node.list = this;
		if (this.current == null) {
			this.current = node;
			node.next = node;
			node.prev = node;
			return node;
		}
		this.current.insertNodeBefore(node);
		return node;
	}

	public function insertAfter(item: T): CircularLinkedNode<T> {
		var node = new CircularLinkedNode<T>(item);
		node.list = this;
		if (this.current == null) {
			this.current = node;
			node.next = node;
			node.prev = node;
			return node;
		}
		this.current.insertNodeAfter(node);
		return node;
	}

	/**
		get current to the next item and return the next item
	**/
	public function next(): CircularLinkedNode<T> {
		if (this.current == null) return null;
		return this.current = this.current.next;
	}

	public function prev(): CircularLinkedNode<T> {
		if (this.current == null) return null;
		return this.current = this.current.prev;
	}

	public function removeNode(node: CircularLinkedNode<T>): Bool {
		if (node.list != this) return false;
		if (this.current == node) {
			// set the current value first
			if (this.current.next == this.current) {
				// this only happens when there is only one item, unless next and prev
				// have been modified outside of this list
				Assert.assert(this.current.prev == this.current);
				this.current = null;
			} else {
				this.current = this.current.next;
			}
		}
		node.prev.next = node.next;
		node.next.prev = node.prev;
		node.next = null;
		node.prev = null;
		node.list = null;
		return true;
	}

	public function findOneNode(func: T->Bool): CircularLinkedNode<T> {
		if (this.current == null) return null;
		if (func(this.current.item)) return this.current;
		var c = this.current.next;
		while (c != this.current) {
			if (func(c.item)) return c;
			c = c.next;
		}
		return null;
	}

	public function findNodeByItem(item: T): CircularLinkedNode<T> {
		if (this.current == null) return null;
		if (this.current.item == item) return this.current;
		var c = this.current.next;
		while (c != this.current) {
			if (c.item == item) return c;
			c = c.next;
		}
		return null;
	}
}
