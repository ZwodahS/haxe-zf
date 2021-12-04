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

	public function runAnims(anims: Array<Animation>, onFinish: Void->Void = null): Animation {
		final batch = new Batch(anims);
		if (onFinish != null) batch.onFinish = onFinish;
		this.run(batch);
		batch.animator = this;
		return batch;
	}

	public function wait(duration: Float, func: Void->Void): Animation {
		return this.runAnim(new Wait(duration), func);
	}

	public function waitFor(waitFunc: Void->Bool, runFunc: Void->Void): Animation {
		return this.runAnim(new WaitFor(waitFunc), runFunc);
	}
}
