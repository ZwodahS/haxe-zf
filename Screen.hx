package common;

class Screen extends h2d.Layers {
    public function new() {
        super();
    }

    public function update(dt: Float): Void {}

    public function render(engine: h3d.Engine): Void {}

    public function onEvent(event: hxd.Event): Void {}

    public function resize(x: Int, y: Int): Void {}

    public function destroy(): Void {}

    public function beginScreenEnter() {} // called when the screen is switched in

    public function doneEntering(): Bool {
        return true;
    }

    public function beginScreenExit() {} // called when the screen is switched out

    public function doneExiting(): Bool {
        return true;
    }
}
