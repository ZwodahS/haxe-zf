package zf;

enum ScreenState {
	Init;
	Entering;
	Ready;
	Exiting;
	Exited;
}

/**
	@stage:stable
**/
class Screen extends h2d.Layers {
	public var state: ScreenState = Init;

	public var game(default, set): Game;

	public function set_game(g: Game): Game {
		this.game = g;
		onGameSet(this.game);
		return this.game;
	}

	function onGameSet(g: Game) {}

	public function new() {
		super();
	}

	public function update(dt: Float): Void {}

	public function render(engine: h3d.Engine): Void {}

	public function onEvent(event: hxd.Event): Void {}

	public function resize(x: Int, y: Int): Void {}

	public function destroy(): Void {}

	public function beginScreenEnter() {} // called when the screen is switched in

	public function onScreenEntered() {};

	public function doneEntering(): Bool {
		return true;
	}

	public function beginScreenExit() {} // called when the screen is switched out

	public function onScreenExited() {};

	public function doneExiting(): Bool {
		return true;
	}

	public function onPadConnected(pad: hxd.Pad) {}

	public function onPadDisconnected(pad: hxd.Pad) {}
}
