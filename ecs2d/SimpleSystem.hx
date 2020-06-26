package common.ecs2d;

class SimpleSystem<E: Entity> extends System<E> {
    var updateFunc: (Float) -> Void;

    public function new(updateFunc: (dt: Float) -> Void) {
        super();
        this.updateFunc = updateFunc;
    }

    override public function update(dt: Float) {
        this.updateFunc(dt);
    }
}
