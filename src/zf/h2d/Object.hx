package zf.h2d;

/**
	Extend h2d.Object to add more fields
**/
class Object extends h2d.Object {
	// ---- For effects ---- //

	/**
		Store all the effects added to the element.
		This should not be added directly.
	**/
	var uiEffects: Array<zf.ef.Effect>;

	public function addEffect(effect: zf.ef.Effect) {
		if (this.uiEffects == null) this.uiEffects = [];
		Assert.assert(this.uiEffects.contains(effect) == false);
		this.uiEffects.push(effect);
	}

	public function removeEffect(effect: zf.ef.Effect) {
		if (this.uiEffects == null) return;
		this.uiEffects.remove(effect);
	}

	public function reset() {
		resetUIEffects();
	}

	public function resetUIEffects() {
		if (this.uiEffects != null) {
			for (e in this.uiEffects) e.dispose();
			this.uiEffects = null;
		}
	}

	override public function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		if (this.uiEffects != null && this.uiEffects.length > 0) {
			var i = 0;
			/**
				Tue 13:46:54 27 Jan 2026
				Sometimes uiEffects will dispose the object and set uiEffects to null,
				so we need to handle this.
			**/
			while (this.uiEffects != null && i < this.uiEffects.length) {
				final ef = this.uiEffects[i];
				final done = ef.update(ctx.elapsedTime) == true;
				if (done == true) {
					this.uiEffects.remove(ef);
					ef.onEffectCompleted();
					ef.remove();
				} else {
					i += 1;
				}
			}
		}
	}
}

/**
	Sat 15:30:15 02 Aug 2025
	There is a small question here. I am not sure if there are objects that are going to extends
	Object instead of Container.
**/
