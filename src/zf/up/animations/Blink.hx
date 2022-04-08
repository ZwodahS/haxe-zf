package zf.up.animations;

class Blink extends Update {
	var object: Alphable;
	var duration: Float;
	var blinkSpeed: Float;

	var blinkedElapsed: Float;
	var isShown: Bool = true;

	public function new(object: Alphable, duration: Float, blinkSpeed: Float) {
		super();
		this.object = object;
		this.duration = duration;
		this.blinkSpeed = blinkSpeed;
		this.blinkedElapsed = blinkSpeed;
	}

	override public function isDone(): Bool {
		return this.duration <= 0;
	}

	override public function update(dt: Float) {
		this.duration -= dt;
		if (duration <= 0) {
			this.object.alpha = 1.0;
			return;
		}
		this.blinkedElapsed += dt;
		if (blinkedElapsed >= this.blinkSpeed) {
			this.isShown = !this.isShown;
			this.object.alpha = this.isShown ? 1.0 : .0;
			this.blinkedElapsed -= this.blinkSpeed;
		}
	}
}
