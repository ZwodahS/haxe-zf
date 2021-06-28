package zf.ds;

using zf.ds.ArrayExtensions;

/**
	extends the List with various utility
**/
@:access(haxe.ds.List)
class ListExtensions {
	// adapted from https://github.com/HaxeFoundation/haxe/blob/4.1.2/std/haxe/ds/ListSort.hx
	// which adapted from https://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
	public static function sort<T>(thisList: haxe.ds.List<T>, cmp: (T, T) -> Int) {
		if (thisList.h == null) return;
		var list = thisList.h;
		var tail = thisList.q;
		tail = null;
		var insize = 1, nmerges, psize = 0, qsize = 0;
		var p, q, e;
		while (true) {
			p = list;
			list = null;
			tail = null;
			nmerges = 0;
			while (p != null) {
				nmerges++;
				q = p;
				psize = 0;
				for (i in 0...insize) {
					psize++;
					q = q.next;
					if (q == null) break;
				}
				qsize = insize;
				while (psize > 0 || (qsize > 0 && q != null)) {
					if (psize == 0) {
						e = q;
						q = q.next;
						qsize--;
					} else if (qsize == 0 || q == null || cmp(p.item, q.item) <= 0) {
						e = p;
						p = p.next;
						psize--;
					} else {
						e = q;
						q = q.next;
						qsize--;
					}
					if (tail != null) tail.next = e; else
						list = e;
					tail = e;
				}
				p = q;
			}
			tail.next = null;
			if (nmerges <= 1) break;
			insize *= 2;
		}
		thisList.h = list;
		thisList.q = tail;
	}

	public static function inFilter<T>(thisList: List<T>, f: T->Bool): List<T> {
		var newHead = null;
		var previous = null;
		var current = thisList.h;
		thisList.length = 0;
		while (current != null) {
			if (f(current.item)) {
				thisList.length += 1;
				if (newHead == null) {
					newHead = current;
				}
				previous = current;
			} else {
				if (previous != null) {
					previous.next = current.next;
				}
			}
			current = current.next;
		}
		thisList.h = newHead;
		thisList.q = previous;
		return thisList;
	}

	public static function shuffle<T>(thisList: List<T>, r: hxd.Rand = null) {
		var arr = [for (item in thisList) item];
		arr.shuffle(r);
		thisList.clear();
		for (item in arr) thisList.push(item);
	}

	public static function contains<T>(thisList: List<T>, item: T): Bool {
		for (i in thisList) {
			if (i == item) return true;
		}
		return false;
	}

	public static function uniqueAdd<T>(thisList: List<T>, item: T): Bool {
		if (contains(thisList, item)) return false;
		thisList.add(item);
		return true;
	}

	public static function firstX<T>(thisList: List<T>, count: Int): Array<T> {
		var items: Array<T> = [];
		var item = thisList.h;
		for (i in 0...count) {
			if (item == null) break;
			items.push(item.item);
			item = item.next;
		}
		return items;
	}

	public static function get<T>(thisList: List<T>, position: Int): T {
		/**
			Slow, but useful if we know what we are doing.
		**/
		var curr = thisList.h;

		for (i in 0...position) {
			if (curr == null) break;
			curr = curr.next;
		}
		return curr.item;
	}

	public static function popItemAtPosition<T>(thisList: List<T>, position: Int): Null<T> {
		var prev = null;
		var curr = thisList.h;
		for (i in 0...position) {
			if (curr == null) break;
			prev = curr;
			curr = curr.next;
		}
		if (curr == null) return null;
		thisList.length--;
		if (prev == null) {
			thisList.h = curr.next;
		} else {
			prev.next = curr.next;
		}
		if (thisList.q == curr) {
			thisList.q = prev; // thisList become the last index
		}
		return curr.item;
	}

	public static function copy<T>(thisList: List<T>): List<T> {
		// shallow copy
		var l = new List<T>();
		for (i in thisList) {
			l.add(i);
		}
		return l;
	}

	public static function removeByFunc<T>(thisList: List<T>, check: T->Bool): T {
		var found = null;
		var current = thisList.h;
		while (current != null) {
			if (check(current.item)) {
				found = current;
				break;
			}
			current = current.next;
		}
		if (found != null) thisList.remove(found.item);
		return found.item;
	}

	public static function toArray<T>(thisList: List<T>): Array<T> {
		return [for (i in thisList) i];
	}
}
