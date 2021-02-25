package zf.animations;

/**
	Batch Animation takes in a list of animations, run them together.
**/
class Batch extends Animation {
	var animations: Array<Animation>;

	public function new(animations: Array<Animation>) {
		super();
		this.animations = animations;
	}

	override public function isDone(): Bool {
		for (a in this.animations) {
			if (!a.isDone()) return false;
		}
		return true;
	}

	override public function update(dt: Float) {
		for (a in this.animations) {
			if (a.isDone()) continue;
			a.update(dt);
		}
	}

	override public function with(animation: Animation): Batch {
		this.animations.push(animation);
		return this;
	}
}
