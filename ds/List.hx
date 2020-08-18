package common.ds;

/**
    extends the List with various utility
**/
class List<T> extends haxe.ds.List<T> {
    // adapted from https://github.com/HaxeFoundation/haxe/blob/4.1.2/std/haxe/ds/ListSort.hx
    // which adapted from https://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
    public function sort(cmp: (T, T) -> Int) {
        if (this.h == null) return;
        var list = this.h;
        var tail = this.q;
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
        this.h = list;
        this.q = tail;
    }

    public function inFilter(f: T->Bool): List<T> {
        var newHead = null;
        var previous = null;
        var current = this.h;
        while (current != null) {
            if (f(current.item)) {
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
        this.h = newHead;
        this.q = previous;
        return this;
    }

    public function shuffle(r: hxd.Rand = null) {
        ListUtils.shuffle(this, r);
    }

    public function contains(item: T): Bool {
        return ListUtils.contains(this, item);
    }

    public function firstX(count: Int): Array<T> {
        var items: Array<T> = [];
        var item = this.h;
        for (i in 0...count) {
            if (item == null) break;
            items.push(item.item);
            item = item.next;
        }
        return items;
    }

    public function get(position: Int): T {
        /**
            Slow, but useful if we know what we are doing.
        **/
        var curr = this.h;

        for (i in 0...position) {
            if (curr == null) break;
            curr = curr.next;
        }
        return curr.item;
    }

    public function popItemAtPosition(position: Int): Null<T> {
        var prev = null;
        var curr = this.h;
        for (i in 0...position) {
            if (curr == null) break;
            prev = curr;
            curr = curr.next;
        }
        if (curr == null) return null;
        if (prev == null) {
            this.h = curr.next;
        } else {
            prev.next = curr.next;
        }
        if (this.q == curr) {
            this.q = prev; // this become the last index
        }
        return curr.item;
    }

    public function copy(): List<T> {
        // shallow copy
        var l = new List<T>();
        for (i in this) {
            l.add(i);
        }
        return l;
    }
}
