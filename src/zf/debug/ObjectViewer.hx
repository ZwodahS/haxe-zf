package zf.debug;

import zf.ui.UIElement;
import zf.h2d.HtmlText;
import zf.ui.ScrollArea;
import zf.h2d.Interactive;

private class TreeNode extends UIElement {
	public var level: Int;
	public var text: HtmlText;
	public var data: Dynamic;
	public var displayName: String;
	public var viewer: ObjectViewer;

	public function new(viewer: ObjectViewer, level: Int, name: String, data: Dynamic) {
		super();
		this.level = level;
		this.data = data;
		this.displayName = name;
		this.text = new HtmlText(viewer.font);
		this.text.text = formatDisplay();
		this.text.textColor = viewer.conf.textColor;
		this.addChild(this.text);

		final size = this.text.getBounds();
		this.addChild(this.interactive = new Interactive(size.width, size.height));
		this.text.x = this.level * 4;
		this.interactive.x = this.level * 4;
	}

	function formatDisplay() {
		var str = '';
		if (this.level > 0) str += '|_ ';
		str += this.displayName;
		var type: String = null;
		var value: String = null;
		switch (Type.typeof(this.data)) {
			case TNull:
				value = 'null';
			case TInt:
				type = 'Int';
				value = '${this.data}';
			case TFloat:
				type = 'Float';
				value = '${this.data}';
			case TBool:
				type = 'Bool';
				value = '${this.data}';
			case TObject:
				type = 'Struct';
			case TClass(Array):
				type = 'Array (${cast (this.data, Array<Dynamic>).length})';
			case TClass(String):
				type = 'String';
				value = '"${this.data}"';
			case TClass(e):
				type = 'Object(${e})';
			case TEnum(e):
				type = 'Enum(${e}}';
				value = '${this.data}';
			default:
		}
		if (type != null) str += ' [<font color="#${StringTools.hex(0xff68f7fa, 6)}">${type}</font>]';
		if (value != null) str += ' [<font color="#${StringTools.hex(0xff44f720, 6)}">${value}</font>]';
		return str;
	}
}

class ObjectViewer extends h2d.Object {
	var treeNodes: Array<TreeNode>;
	var tree: h2d.Flow;

	var rootNodes: Array<TreeNode>;

	public var conf = {
		width: 0,
		height: 0,
		textColor: 0xfffffbe5,
	}

	public var font: h2d.Font;

	var scrollArea: ScrollArea;

	public function new(font: h2d.Font) {
		super();
		this.font = font;
	}

	public function init() {
		this.tree = new h2d.Flow();
		this.tree.layout = Vertical;
		this.tree.verticalSpacing = 2;
		this.treeNodes = [];
		this.rootNodes = [];

		this.scrollArea = ScrollArea.make({
			object: this.tree,
			size: [this.conf.width - 4, this.conf.height - 4],
			cursorColor: this.conf.textColor,
		});
		this.scrollArea.interactive.propagateEvents = true;
		this.addChild(this.scrollArea);
	}

	public function clear() {
		this.tree.removeChildren();
		this.treeNodes.clear();
	}

	public function addNode(object: Dynamic, name: String, expand: Bool = false) {
		final node = createNode(0, name, object);
		this.rootNodes.push(node);
		this.treeNodes.push(node);
		if (expand == true) {
			onNodeClick(node);
		} else {
			redraw();
		}
	}

	function onNodeClick(n: TreeNode) {
		final index = this.treeNodes.indexOf(n);
		if (index == -1) return;
		// get the next index
		final nextNode = this.treeNodes[index + 1];
		final isExpanded = nextNode != null && nextNode.level == n.level + 1;
		if (isExpanded == true) {
			// remove the expanded
			var len = 0;
			for (i in (index + 1)...this.treeNodes.length) {
				if (n.level == this.treeNodes[i].level) break;
				len += 1;
			}
			this.treeNodes.splice(index + 1, len);
		} else {
			// expand the object
			var insertIndex = index + 1;
			var nodes = expandNodes(n);
			for (n in nodes) this.treeNodes.insert(insertIndex++, n);
		}
		redraw();
	}

	function expandNodes(n: TreeNode): Array<TreeNode> {
		var nodes: Array<TreeNode> = [];
		switch (Type.typeof(n.data)) {
			case TClass(Array):
				final arr: Array<Dynamic> = cast n.data;
				for (ind => object in arr) {
					final node = createNode(n.level + 1, '[${ind}]', object);
					if (node != null) nodes.push(node);
				}
			case TClass(String):
			case TClass(haxe.ds.StringMap):
				final map: haxe.ds.StringMap<Dynamic> = cast n.data;
				for (key => value in map) {
					final node = createNode(n.level + 1, key, value);
					if (node != null) nodes.push(node);
				}
			case TClass(haxe.ds.IntMap):
				final map: haxe.ds.IntMap<Dynamic> = cast n.data;
				for (key => value in map) {
					final node = createNode(n.level + 1, '${key}', value);
					if (node != null) nodes.push(node);
				}
			case TClass(e):
				for (field in Reflect.fields(n.data)) {
					final node = createNode(n.level + 1, field, Reflect.field(n.data, field));
					if (node != null) nodes.push(node);
				}
			case TObject:
				for (field in Reflect.fields(n.data)) {
					final node = createNode(n.level + 1, field, Reflect.field(n.data, field));
					if (node != null) nodes.push(node);
				}
			default:
		}
		return nodes;
	}

	function createNode(level: Int, name: String, object: Dynamic): TreeNode {
		var expand = true;
		switch (Type.typeof(object)) {
			case TNull, TInt, TFloat, TBool, TClass(String):
				expand = false;
			case TFunction:
				return null;
			default:
		}
		final node = new TreeNode(this, level, name, object);
		if (expand == true) {
			node.addOnClickListener("ObjectViewer", (_) -> {
				onNodeClick(node);
			});
		}
		return node;
	}

	function redraw() {
		this.tree.removeChildren();
		for (node in this.treeNodes) this.tree.addChild(node);
		this.scrollArea.onObjectUpdated();
	}
}
