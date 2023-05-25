package zf.debug;

import zf.ui.UIElement;
import zf.h2d.HtmlText;
import zf.ui.ScrollArea;
import zf.h2d.Interactive;
import zf.ui.Button;
import zf.MessageDispatcher.MessageDispatcherListener;

import hxd.Key;

/**
	Provide a UI to manage any message dispatcher

	Idea:

	1. Track how many listener each messages has.
	2. Store all the messages emitted
	3. Store all debug messages in each messages.

	This only works in debug mode, as many of the code in messages are not compiled in outside of debug.
**/
private class MessageNode extends UIElement {
	public var message: Message;
	public var text: HtmlText;
	public var dispatcher: MessageDispatcher;

	public function new(parent: OverlayMessages, dispatcher: MessageDispatcher, message: Message) {
		super();
		this.message = message;
		this.dispatcher = dispatcher;

		this.text = new HtmlText(parent.fonts[0]);
		this.text.text = formatText();
		this.text.textColor = parent.conf.textColor;
		this.addChild(this.text);

		final size = this.text.getBounds();
		this.addChild(this.interactive = new Interactive(size.width, size.height));
	}

	function formatText() {
		@:privateAccess final listeners = this.dispatcher.listenersMap[this.message.type];
		final count = listeners == null ? 0 : listeners.length;
		return '${message.type} [${count} listeners]';
	}
}

class OverlayMessages extends h2d.Object {
	var game: Game;

	public var fonts: Array<h2d.Font>;

	public var dispatcher(default, set): MessageDispatcher;

	var listenerId: Int = -1;

	var enabled: Bool = false;

	public function set_dispatcher(v: MessageDispatcher): MessageDispatcher {
		if (this.dispatcher != null) {
			this.dispatcher.remove(this.listenerId);
			this.listenerId = -1;
		}
		this.dispatcher = v;
		if (this.dispatcher != null) {
			this.listenerId = this.dispatcher.listenAll(onMessageDispatch);
		}
		return this.dispatcher;
	}

	public var conf = {
		alpha: 0.9,
		bgColor: 0xff111012,
		width: 0, // set by DebugOverlay
		height: 0, // set by DebugOverlay
		textColor: 0xfffffbe5,
		button: {
			size: [50, 12],
			bgColor: [0xff111012, 0xff8c7f5a, 0xfffff703, 0xff3f7082],
			textColor: 0xfffffbe5,
		},
	}

	public var tree: h2d.Flow;
	public var treeNodes: Array<MessageNode>;

	var scrollArea: ScrollArea;

	var viewer: ObjectViewer;

	public function new(fonts: Array<h2d.Font>, game: Game) {
		super();
		this.game = game;
		this.fonts = fonts;
	}

	public function init() {
		final width = this.conf.width;
		final height = Std.int((this.conf.height - 5 - this.conf.button.size[1] - 4) / 2);

		final messagesBg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		messagesBg.width = width;
		messagesBg.height = height;
		messagesBg.alpha = this.conf.alpha;
		this.addChild(messagesBg);

		final viewerBg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		viewerBg.width = width;
		viewerBg.height = height;
		viewerBg.alpha = this.conf.alpha;
		viewerBg.y = height + 4;
		this.addChild(viewerBg);

		final flow = new h2d.Flow();
		flow.horizontalSpacing = 4;
		flow.layout = Horizontal;
		flow.y = this.conf.height - this.conf.button.size[1];
		this.addChild(flow);

		final btn = makeButton("Clear");
		btn.addOnClickListener("OverlayMessages", (e) -> {
			clearAllMessages();
		});
		flow.addChild(btn);

		final btn: ObjectsButton = cast makeButton("Enable");
		btn.addOnClickListener("OverlayMessages", (e) -> {
			this.enabled = !this.enabled;
			btn.text = this.enabled == true ? "Disable" : "Enable";
		});
		flow.addChild(btn);

		this.tree = new h2d.Flow();
		this.tree.layout = Vertical;
		this.tree.verticalSpacing = 2;
		this.treeNodes = [];

		this.scrollArea = ScrollArea.make({
			object: this.tree,
			size: [width - 4, height - 4],
			cursorColor: this.conf.textColor,
		});
		this.scrollArea.x = 2;
		this.scrollArea.y = 2;
		this.addChild(this.scrollArea);

		this.scrollArea.addOnKeyDownListener("OverlayMessages", (e) -> {
			if (e.keyCode == Key.ESCAPE) hide();
		});

		this.viewer = new ObjectViewer(this.fonts[0]);
		this.viewer.conf.width = width - 4;
		this.viewer.conf.height = height - 4;
		this.viewer.x = 2;
		this.viewer.y = height + 4 + 2;
		this.viewer.init();
		this.addChild(viewer);
	}

	public function onShow() {}

	dynamic public function hide() {}

	function makeButton(text: String): Button {
		final btn = Button.fromColor({
			defaultColor: this.conf.button.bgColor[0],
			hoverColor: this.conf.button.bgColor[1],
			disabledColor: this.conf.button.bgColor[2],
			selectedColor: this.conf.button.bgColor[3],
			width: this.conf.button.size[0],
			height: this.conf.button.size[1],
			font: this.fonts[1],
			textColor: this.conf.button.textColor,
			text: text,
		});
		return btn;
	}

	function redraw() {
		this.tree.removeChildren();
		for (node in this.treeNodes) {
			this.tree.addChild(node);
		}
		this.scrollArea.onObjectUpdated();
	}

	function onMessageDispatch(message: Message) {
		if (this.enabled == false) return;
		final node = new MessageNode(this, this.dispatcher, message);
		node.addOnClickListener("OverlayMessages", (e) -> {
			this.viewer.clear();
			this.viewer.addNode(message, "message", true);
		});
		this.treeNodes.push(node);
		this.tree.addChild(node);
		this.scrollArea.onObjectUpdated();
	}

	public function clearAllMessages() {
		this.viewer.clear();
		this.treeNodes.clear();
		this.tree.removeChildren();
		this.scrollArea.onObjectUpdated();
	}
}
