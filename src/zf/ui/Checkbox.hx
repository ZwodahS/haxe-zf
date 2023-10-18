package zf.ui;

typedef CheckboxConf = {
	public var objects: Array<h2d.Object>;
}

/**
	A checkbox extends UIElement and provide the proper rendering using the toggled state.

	A checkbox usually have a lot more frames than a normal button.

	- [0] default (!toggled + !hovered)
	- [1] hover (!toggled + hovered)
	- [2] toggled (toggled + !hovered)
	- [3] toggled_hover (toggled + hovered)
	- [4] disabled
**/
class Checkbox extends UIElement {
	var frames: Array<h2d.Object>;

	var display: h2d.Object;

	function new() {
		super();
		this.addChild(this.display = new h2d.Object());
		this.frames = [];
		this.addOnClickListener("Checkbox", (e) -> {
			this.toggled = !this.toggled;
			onToggled(this.toggled);
		});
	}

	override public function updateRendering() {
		for (o in this.frames) o.visible = false;

		inline function showFrame(f: Int) {
			if (this.frames.length > f) this.frames[f].visible = true;
		}

		if (this.disabled == true) {
			showFrame(4);
		} else if (this.toggled == false) {
			if (this.isOver == true) {
				showFrame(1);
			} else {
				showFrame(0);
			}
		} else {
			if (this.isOver == true) {
				showFrame(3);
			} else {
				showFrame(2);
			}
		}
		onStateChanged();
	}

	/**
		Sometimes you might want to change the button even further when the state changed.
	**/
	dynamic public function onStateChanged() {}

	dynamic public function onToggled(v: Bool) {}

	public static function fromObjects(conf: CheckboxConf, cb: Checkbox = null): Checkbox {
		if (cb == null) cb = new Checkbox();
		if (conf.objects == null || conf.objects.length != 5) return null;
		for (o in conf.objects) {
			cb.display.addChild(o);
			cb.frames.push(o);
		}
		final size = conf.objects[0].getSize();
		cb.display.addChild(cb.interactive = new zf.h2d.Interactive(size.width, size.height));
		cb.updateRendering();
		return cb;
	}
}
