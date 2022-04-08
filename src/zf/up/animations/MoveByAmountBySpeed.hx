package zf.up.animations;

class MoveByAmountBySpeed extends Update {
	var object: Positionable;
	var amount: Point2f;
	var amountLeft: Point2f;
	var speed: Point2f;

	public function new(object: Positionable, moveAmount: Point2f, speeds: Point2f = null, speed: Float = 1) {
		super();
		this.object = object;
		this.amount = moveAmount.copy();
		this.amountLeft = moveAmount.copy();
		this.speed = speeds != null ? speeds : [speed, speed];
	}

	override public function isDone(): Bool {
		return (this.amountLeft.x == 0 && this.amountLeft.y == 0);
	}

	override public function update(dt: Float) {
		if (this.isDone()) {
			return;
		}

		var moveX = dt * this.speed.x * MathUtils.sign(this.amountLeft.x);
		if (moveX < 0) {
			moveX = Math.max(this.amountLeft.x, moveX);
		} else {
			moveX = Math.min(this.amountLeft.x, moveX);
		}
		this.amountLeft.x -= moveX;
		this.object.x += moveX;

		var moveY = dt * this.speed.y * MathUtils.sign(this.amountLeft.y);
		if (moveY < 0) {
			moveY = Math.max(this.amountLeft.y, moveY);
		} else {
			moveY = Math.min(this.amountLeft.y, moveY);
		}
		this.amountLeft.y -= moveY;
		this.object.y += moveY;
	}
}
