package common.ecs;

class SimpleSystem extends System {
    var updateFunc: (Float) -> Void;

    public function new(name: String, updateFunc: (dt: Float) -> Void) {
        super(name);
        this.updateFunc = updateFunc;
    }

    override public function update(dt: Float) {
        this.updateFunc(dt);
    }
}
