package zf.ui;

/**
    Provide a data container for

    1. Storing menu items
    2. Manipulating menu item
    3. Performing action on the menu item
**/
@:allow(zf.ui.MenuList)
class MenuItem extends h2d.Object {
    public var index(default, null): Int;
    public var selected(default, set): Bool;

    var menu: MenuList;

    public function set_selected(s: Bool): Bool {
        return this.selected = s;
    }

    public function activate() {}

    public function removeFromMenu() {
        if (this.menu == null) return;
        this.menu.removeItem(this);
    }
}

class MenuList extends h2d.Layers {
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

    public function reselectItem() {
        var i = selectedItem;
        if (i != null) i.selected = true;
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

    public function addItem(item: MenuItem, ?updateSize: Bool = true) {
        var prevSize = this.items.length;
        @:privateAccess item.index = this.items.length;
        this.items.push(item);
        item.menu = this;
        if (updateSize) sizeUpdated(prevSize, this.items.length);
    }

    public function addItems(items: Iterable<MenuItem>) {
        var prevSize = this.items.length;
        // NOTE: updateSize flag is a hack. Ideally, the "correct" way might be to have a internal _addItem function
        // that is okay for the most part but that requires changing a lot of code in child classes.
        // might still be dangerous to do it this way. Need to think about it
        for (i in items) addItem(i, false);
        sizeUpdated(prevSize, this.items.length);
    }

    public function removeItem(item: MenuItem): Bool {
        var prevSize = this.items.length;
        if (!this.items.remove(item)) return false;
        for (ind => i in this.items) {
            @:privateAccess i.index = ind;
            indexUpdated(i, ind);
        }
        item.menu = null;
        sizeUpdated(prevSize, this.items.length);
        return true;
    }

    public function replaceItem(item: MenuItem, index: Int): MenuItem {
        if (index < 0 || index >= this.items.length) return null;
        var oldValue = this.items[index];
        this.items[index] = item;
        item.selected = oldValue.selected;
        @:privateAccess item.index = oldValue.index;
        return oldValue;
    }

    public function onClose() {}

    public function indexUpdated(item: MenuItem, index: Int) {}

    dynamic public function sizeUpdated(prevSize: Int, newSize: Int) {}
}

/**
    A simple vertical menu just have item height and item spacing and place it in a vertical list.
**/
class VerticalMenuList extends MenuList {
    var itemHeight: Int;
    var itemSpacing: Int;

    public var height(get, never): Int;

    public function get_height(): Int {
        return (itemHeight * this.items.length) + (itemSpacing * (this.items.length - 1));
    }

    public function new(itemHeight: Int, itemSpacing: Int) {
        super();
        this.itemHeight = itemHeight;
        this.itemSpacing = itemSpacing;
    }

    override public function addItem(item: MenuItem, ?updateSize: Bool = true) {
        super.addItem(item, updateSize);
        indexUpdated(item, item.index);
        item.selected = false;
        this.add(item, 10);
    }

    override public function removeItem(item: MenuItem): Bool {
        var success = super.removeItem(item);
        if (success) item.remove();
        if (this.selectedIndex >= this.items.length) this.selectedIndex = this.items.length - 1;
        return success;
    }

    override public function replaceItem(item: MenuItem, index: Int): MenuItem {
        var oldValue = super.replaceItem(item, index);
        if (oldValue == null) return null;
        this.removeChild(oldValue);
        this.add(item, 10);
        indexUpdated(item, index);
        return oldValue;
    }

    override public function clear() {
        for (i in this.items) i.remove();
        super.clear();
    }

    override public function indexUpdated(item: MenuItem, index: Int) {
        var y = index == 0 ? 0 : (index * itemHeight) + ((index - 1) * itemSpacing);
        item.y = y;
        if (index == this.selectedIndex) item.selected = true;
    }
}
