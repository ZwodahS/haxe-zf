package zf.animations;

class AlphaTo extends Animation {
	var object: Alphable;
	var alphaTo: Float;
	var alphaSpeed: Float;

	public function new(object: Alphable, alphaTo: Float, alphaSpeed: Float = 1.0) {
		super();
		this.object = object;
		this.alphaTo = alphaTo;
		this.alphaSpeed = alphaSpeed;
	}

	override public function isDone(): Bool {
		return this.object.alpha == this.alphaTo;
	}

	override public function update(dt: Float) {
		if (this.isDone()) {
			return;
		}

		var sign = this.object.alpha > this.alphaTo ? -1 : 1;
		var delta = this.alphaSpeed * dt * sign;
		if (delta < 0) {
			this.object.alpha = Math.max(this.object.alpha + delta, this.alphaTo);
		} else {
			this.object.alpha = Math.min(this.object.alpha + delta, this.alphaTo);
		}
	}
}
