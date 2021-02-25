package zf.animations;

import zf.h2d.WrappedBatchElement;

// Mon Sep  7 13:32:51 2020
// TODO generalise this later
class Explode extends Animation {
	// takes in an bitmap, split into certain number of square and move them into different direction
	var original: h2d.Bitmap;
	var animations: Array<Animation>;
	var started: Bool;
	var spritebatch: h2d.SpriteBatch;

	var split: Int;
	var explodeDuration: Float;
	var deviation: Float;

	public function new(bitmap: h2d.Bitmap, split: Int = 8, explodeDuration: Float = .7,
			deviation: Float = 32) {
		super();
		this.original = bitmap;
		this.started = false;
		this.animations = [];
		this.spritebatch = new h2d.SpriteBatch(bitmap.tile);
		this.explodeDuration = explodeDuration;
		this.split = split;
		this.deviation = deviation;
	}

	var timeElapsed: Float = 0.;

	override public function isDone(): Bool {
		return this.timeElapsed >= this.explodeDuration;
	}

	override public function update(dt: Float) {
		if (this.isDone()) return;
		if (!started) {
			var width = this.original.tile.width / this.split;
			var height = this.original.tile.height / this.split;
			for (x in 0...this.split) {
				for (y in 0...this.split) {
					var t = this.original.tile.sub(x * width, y * height, width, height);
					var b = this.spritebatch.alloc(t);
					b.x = this.original.x + x * width;
					b.y = this.original.y + y * height;
					b.r = this.original.color.r;
					b.g = this.original.color.g;
					b.b = this.original.color.b;
					b.alpha = this.original.alpha;
					var xMove = Random.int(-100, 100) / 50.0 * this.deviation;
					var yMove = Random.int(-100, 100) / 50.0 * this.deviation;
					this.animations.push(new MoveBySpeedByDuration(new WrappedBatchElement(b),
						this.explodeDuration, [xMove, yMove]));
					this.animations.push(new AlphaTo(new WrappedBatchElement(b), 0.0,
						0.5 / this.explodeDuration));
				}
			}
			this.original.parent.addChild(this.spritebatch);
			this.original.remove();
			this.started = true;
			this.timeElapsed = 0.;
		}
		timeElapsed += dt;
		for (a in this.animations) {
			a.update(dt);
		}
		if (this.isDone()) {
			this.spritebatch.remove();
		}
	}
}
