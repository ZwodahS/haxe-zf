package zf.ui;

class Button extends h2d.Layers {
	public var disabled(default, set): Bool = false;

	var isOver: Bool = false;
	var interactive: h2d.Interactive;

	public var width(default, null): Int;
	public var height(default, null): Int;

	public function set_disabled(b: Bool): Bool {
		this.disabled = b;
		updateButton();
		return this.disabled;
	}

	public function new(width: Int, height: Int) {
		super();
		this.width = width;
		this.height = height;
		this.interactive = new h2d.Interactive(width, height, this);
		interactive.onOver = function(e: hxd.Event) {
			this.isOver = true;
			updateButton();
			onOver();
		}
		interactive.onOut = function(e: hxd.Event) {
			this.isOver = false;
			updateButton();
			onOut();
		}
		interactive.onClick = function(e: hxd.Event) {
			onClick();
		}
		interactive.onPush = function(e: hxd.Event) {
			onPush();
		}
		interactive.onRelease = function(e: hxd.Event) {
			this.isOver = false;
			updateButton();
			onRelease();
		}
		interactive.cursor = Default;
	}

	dynamic public function onOut() {}

	dynamic public function onOver() {}

	dynamic public function onClick() {}

	dynamic public function onPush() {}

	dynamic public function onRelease() {}

	function updateButton() {}
}
