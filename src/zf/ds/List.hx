package zf.ds;

import zf.Assert;

@:allow(zf.ds.List)
class ListNode<T> {
	public var next(default, null): ListNode<T>;
	public var prev(default, null): ListNode<T>;
	public var item(default, null): T;
	public var list(default, null): List<T>;

	function new(list: List<T>, item: T) {
		this.list = list;
		this.item = item;
	}

	inline function setNext(n: ListNode<T>) {
		this.next = n;
		n.prev = this;
	}
}

/**
	Replace haxe.ds.List with a doubly linked list and pool-ed node.
	Expose node unlike haxe.ds.List if more control is needed.

	Can be dropped in to replace haxe.ds.List.
**/
class List<T> {
	public var head: ListNode<T>;
	public var tail: ListNode<T>;
	var pool: ListNode<T>;

	public var length(default, null): Int;

	public function new() {
		this.length = 0;
	}

	function makeNode(item: T) {
		if (this.pool != null) {
			final node = this.pool;
			this.pool = this.pool.next;
			node.next = null;
			if (this.pool != null) this.pool.prev = null;
			node.item = item;
			return node;
		} else {
			final node = new ListNode<T>(this, item);
			return node;
		}
	}

	/**
		Add item to the end of the list
	**/
	public function add(item: T) {
		final node = makeNode(item);
		if (this.tail != null) {
			this._addAfterNode(node, tail);
		} else {
			this.head = this.tail = node;
			this.length += 1;
		}
	}

	/**
		Add item to the start of the list
	**/
	public function push(item: T) {
		final node = makeNode(item);
		if (this.head != null) {
			this._addBeforeNode(node, head);
		} else {
			this.head = this.tail = node;
			this.length += 1;
		}
	}

	function _addAfterNode(node: ListNode<T>, afterNode: ListNode<T>) {
		Assert.assert(node.next == null);
		Assert.assert(node.prev == null);
		final next = afterNode.next;
		afterNode.next = node;
		node.prev = afterNode;

		if (next != null) {
			node.next = next;
			next.prev = node;
		} else {
			Assert.assert(this.tail == afterNode);
			this.tail = node;
		}

		this.length += 1;
	}

	function _addBeforeNode(node: ListNode<T>, beforeNode: ListNode<T>) {
		Assert.assert(node.next == null);
		Assert.assert(node.prev == null);
		final prev = beforeNode.prev;
		beforeNode.prev = node;
		node.next = beforeNode;

		if (prev != null) {
			node.prev = prev;
			prev.next = node;
		} else {
			Assert.assert(this.head == beforeNode);
			this.head = node;
		}

		this.length += 1;
	}

	function _removeNode(node: ListNode<T>) {
		final next = node.next;
		final prev = node.prev;

		if (next != null) {
			next.prev = prev;
		} else {
			this.tail = prev;
		}
		if (prev != null) {
			prev.next = next;
		} else {
			this.head = next;
		}

		// return it to the pool
		node.next = this.pool;
		node.prev = null;
		node.item = null;
		this.pool = node;
		this.length -= 1;
	}

	/**
		Clear the list
	**/
	public function clear() {
		var next = this.pool;
		// flush the prev/item for all the node
		while (next != null) {
			next.prev = null;
			next.item = null;
			next = next.next;
		}
		// we just need to set the pool to the head since all the next are set up.
		this.pool = this.head;

		// clear the head and tail
		this.head = null;
		this.tail = null;
	}

	/**
		Return a list filtered with function.
	**/
	public function filter(f: T->Bool): List<T> {
		final list = new List<T>();
		for (i in this) {
			if (f(i) == true) list.add(i);
		}
		return list;
	}

	/**
		Return the first item in the list, null if the list is empty
	**/
	public function first(): Null<T> {
		return this.head?.item;
	}

	/**
		Return the last item in the list, null if the list is empty
	**/
	public function last(): Null<T> {
		return this.tail?.item;
	}

	/**
		Return if the list is empty
	**/
	public function isEmpty(): Bool {
		return this.head == null;
	}

	/**
		Return a iterator for the list
	**/
	public function iterator(): ListIterator<T> {
		return new ListIterator<T>(this.head);
	}

	public function reverseIterator(): ReverseListIterator<T> {
		return new ReverseListIterator<T>(this.tail);
	}

	/**
		Returns a string representation of this List, with separator separating each element.
	**/
	public function join(separator: String): String {
		return [for (i in this) i].join(separator);
	}

	/**
		Returns a new list where all elements have been converted by the function f.
	**/
	public function map<X>(f: T->X): List<X> {
		final list = new List<X>();
		for (n in this) {
			list.add(f(n));
		}
		return list;
	}

	/**
		Remove and return the first element in the list. return null if the list is empty.
	**/
	public function pop(): Null<T> {
		if (this.head == null) return null;
		final item = this.head.item;
		_removeNode(this.head);
		return item;
	}

	/**
		Remove the first instance of item. null otherwise.
	**/
	public function remove(item: T): Null<T> {
		var n = this.head;
		while (n != null) {
			if (n.item != item) {
				n = n.next;
				continue;
			}
			final i = n.item;
			_removeNode(n);
			return i;
		}
		return null;
	}

	/**
		Remove the last instance of item, null otherwise.
	**/
	public function removeLast(item: T): Null<T> {
		var n = this.tail;
		while (n != null) {
			if (n.item != item) {
				n = n.prev;
				continue;
			}
			final i = n.item;
			_removeNode(n);
			return i;
		}
		return null;
	}

	/**
		Return the string representation of the list.
	**/
	public function toString(): String {
		return '{${this.join(",")}}';
	}

	public function toArray(): Array<T> {
		return [for (i in this) i];
	}
}

private class ListIterator<T> {
	var head: ListNode<T>;

	public inline function new(head: ListNode<T>) {
		this.head = head;
	}

	public inline function hasNext(): Bool {
		return this.head != null;
	}

	public inline function next(): T {
		final item = this.head.item;
		this.head = this.head.next;
		return item;
	}
}

private class ReverseListIterator<T> {
	var tail: ListNode<T>;

	public inline function new(tail: ListNode<T>) {
		this.tail = tail;
	}

	public inline function hasNext(): Bool {
		return this.tail != null;
	}

	public inline function next(): T {
		final item = this.tail.item;
		this.tail = this.tail.prev;
		return item;
	}
}

private class ListKeyValueIterator<T> {
	var ind: Int;
	var head: ListNode<T>;

	public inline function new(head: ListNode<T>) {
		this.head = head;
		this.ind = 0;
	}

	public inline function hasNext(): Bool {
		return this.head != null;
	}

	public inline function next(): {key: Int, value: T} {
		final item = this.head.item;
		this.head = this.head.next;
		return {value: item, key: this.ind++};
	}
}
/**
	Mon 14:23:32 02 Dec 2024
	Probably need to implement all the ListExtension methods here as well, will implement as needed.
**/
