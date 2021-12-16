package zf;

class Console extends h2d.Console {
	var g: Game;

	public function new(font, ?parent, g: Game) {
		this.g = g;
		super(font, parent);
	}

	override public function show() {
		super.show();
#if debug
		@:privateAccess g.consoleBg.visible = true;
#end
	}

	override public function hide() {
		super.hide();
#if debug
		@:privateAccess g.consoleBg.visible = false;
#end
	}
}
