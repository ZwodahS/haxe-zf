package common.animations;

/**
**/
class Animation implements common.Updater.Updatable {
    public var onFinish: () -> Void;
    public var animator: Animator;

    public function new() {}

    public function finish() {
        if (this.onFinish != null) {
            onFinish();
        }
    }

    public function isDone(): Bool {
        return true;
    }

    public function update(dt: Float) {}

    public function stop(): Bool {
        if (this.animator == null) return false;
        return this.animator.stop(this);
    }

    /**
        For easy chaining construction
    **/
    public function then(animation: Animation): Chain {
        var animations: Array<Animation> = [this, animation];
        return new Chain(animations);
    }

    public function with(animation: Animation): Batch {
        var animations: Array<Animation> = [this, animation];
        return new Batch(animations);
    }

    public function whenDone(onFinish: () -> Void): Animation {
        this.onFinish = onFinish;
        return this;
    }
}
