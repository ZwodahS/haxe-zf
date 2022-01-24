package zf.animations;

class MoveToLocationBySpeed extends Animation {
	var object: Positionable;
	var destination: Point2f;
	var speed: Point2f;

	public function new(object: Positionable, destination: Point2f, speeds: Point2f = null, speed: Float = 1) {
		super();
		this.object = object;
		this.destination = destination;
		// aboslute the speed
		this.speed = speeds != null ? speeds.abs : [speed, speed];
	}

	override public function isDone(): Bool {
		return this.destination == [this.object.x, this.object.y];
	}

	override public function update(dt: Float) {
		if (this.isDone()) {
			return;
		}

		if (this.object.x != this.destination.x) {
			var direction = this.object.x > this.destination.x ? -1 : 1;
			var moveX = this.speed.x * dt * direction;
			if (moveX < 0) {
				this.object.x = Math.max(this.object.x + moveX, this.destination.x);
			} else {
				this.object.x = Math.min(this.object.x + moveX, this.destination.x);
			}
		}

		if (this.object.y != this.destination.y) {
			var direction = this.object.y > this.destination.y ? -1 : 1;
			var moveY = this.speed.y * dt * direction;
			if (moveY < 0) {
				this.object.y = Math.max(this.object.y + moveY, this.destination.y);
			} else {
				this.object.y = Math.min(this.object.y + moveY, this.destination.y);
			}
		}
	}
}
