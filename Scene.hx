
package common;

interface Scene {
    public function update(dt: Float): Void;
    public function render(engine: h3d.Engine): Void;
    public function onEvent(event: hxd.Event): Void;
}
