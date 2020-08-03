package common.animations;

class Animator extends common.Updater { // extends the Updater since most of it is the same
    public function new() {
        super();
    }

    public function runAnim(anim: Animation, onFinish: () -> Void = null) {
        if (onFinish != null) anim.onFinish = onFinish;
        this.run(anim);
        anim.animator = this;
    }
}
