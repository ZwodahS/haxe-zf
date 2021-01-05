package zf.ui;

/**
    Provide a data container for

    1. Storing menu items
    2. Manipulating menu item
    3. Performing action on the menu item
**/
class MenuItem extends h2d.Object {
    public var selected(default, set): Bool;

    public function set_selected(s: Bool): Bool {
        return this.selected = s;
    }

    public function activate() {}
}

class MenuList extends h2d.Object {
    public var items: Array<MenuItem>;

    public var wrapped: Bool = true;

    public var selectedIndex(default, set): Int = -1;

    public function set_selectedIndex(i: Int): Int {
        var prev = this.selectedIndex;
        this.selectedIndex = i;
        updateSelect(prev, this.selectedIndex);
        return this.selectedIndex;
    }

    public var selectedItem(get, never): MenuItem;

    public function get_selectedItem(): MenuItem {
        return (selectedIndex < 0 || selectedIndex >= items.length) ? null : items[selectedIndex];
    }

    public function new() {
        super();
        this.items = [];
    }

    public function previous() {
        if (outOfBound(selectedIndex)) return;
        var prevIndex = selectedIndex;
        selectedIndex -= 1;
        if (selectedIndex < 0) selectedIndex = (wrapped ? items.length - 1 : 0);
        updateSelect(prevIndex, selectedIndex);
    }

    public function next() {
        if (outOfBound(selectedIndex)) return;
        var prevIndex = selectedIndex;
        selectedIndex += 1;
        if (selectedIndex >= items.length) selectedIndex = (wrapped ? 0 : items.length - 1);
        updateSelect(prevIndex, selectedIndex);
    }

    function updateSelect(prev, curr) {
        if (prev == curr) return; // no change
        if (!outOfBound(prev)) {
            items[prev].selected = false;
        }
        if (!outOfBound(curr)) {
            items[curr].selected = true;
        }
    }

    inline function outOfBound(i: Int): Bool {
        return i < 0 || i >= items.length;
    }

    // activate the current item
    public function activate() {
        if (selectedItem == null) return;
        selectedItem.activate();
    }

    public function clear() {
        this.items = [];
        this.selectedIndex = -1;
    }

    public function addItem(item: MenuItem) {
        this.items.push(item);
    }
}

/**
    A simple vertical menu just have item height and item spacing and place it in a vertical list.
**/
class VerticalMenuList extends MenuList {
    var itemHeight: Int;
    var itemSpacing: Int;

    public function new(itemHeight: Int, itemSpacing: Int) {
        super();
        this.itemHeight = itemHeight;
        this.itemSpacing = itemSpacing;
    }

    override public function addItem(item: MenuItem) {
        var y = this.items.length == 0 ? 0 : (this.items.length * itemHeight)
            + ((this.items.length - 1) * itemSpacing);
        super.addItem(item);
        item.y = y;
        item.selected = false;
        this.addChild(item);
    }

    override public function clear() {
        for (i in this.items) i.remove();
        super.clear();
    }
}
