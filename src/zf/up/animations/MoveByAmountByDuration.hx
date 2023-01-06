package zf.up.animations;

/**
	@stage:stable
**/
class MoveByAmountByDuration extends Update {
	var object: Positionable;
	var start: Point2f;
	var amount: Point2f;
	var duration: Float;
	var delta: Float;
	var step: Point2f;

	var isInit: Bool = false;

	public function new(object: Positionable, amount: Point2f, duration: Float) {
		super();
		this.object = object;
		this.amount = amount;
		this.duration = duration;
		this.delta = 0;
	}

	override public function isDone(): Bool {
		return this.delta >= this.duration;
	}

	function initSteps() {
		this.start = [this.object.x, this.object.y];
		this.step = this.amount * (1 / duration);
		this.isInit = true;
	}

	override public function update(dt: Float) {
		if (!this.isInit) initSteps();
		this.delta += dt;
		if (this.delta > this.duration) this.delta = this.duration;
		var currentPosition = this.start + (this.step * this.delta);
		this.object.x = currentPosition.x;
		this.object.y = currentPosition.y;
	}
}
