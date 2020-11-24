package zf.animations;

class Animator extends zf.Updater { // extends the Updater since most of it is the same
    public function new() {
        super();
    }

    public function runAnim(anim: Animation, onFinish: Void->Void = null): Animation {
        if (onFinish != null) anim.onFinish = onFinish;
        this.run(anim);
        anim.animator = this;
        return anim;
    }

    public function wait(duration: Float, func: Void->Void) {
        this.runAnim(new Wait(duration), func);
    }
}
