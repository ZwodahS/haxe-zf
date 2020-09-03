package common.animations;

/**
    Chain Animation takes in a list of animations, and run them one after another
**/
class Chain extends Animation {
    var currentIndex: Int;
    var animations: Array<Animation>;

    public function new(animations: Array<Animation>) {
        super();
        this.currentIndex = 0;
        this.animations = animations;
    }

    override public function isDone(): Bool {
        return this.currentIndex >= this.animations.length;
    }

    override public function update(dt: Float) {
        if (this.isDone()) return;
        this.animations[this.currentIndex].update(dt);
        if (this.animations[this.currentIndex].isDone()) {
            this.currentIndex++;
        }
    }

    override public function then(animation: Animation): Chain {
        this.animations.push(animation);
        return this;
    }

    override public function wait(duration: Float): Chain {
        this.animations.push(new Wait(duration));
        return this;
    }
}
