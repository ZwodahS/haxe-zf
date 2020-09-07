package common.animations;

import common.h2d.WrappedBatchElement;

// Mon Sep  7 13:32:51 2020
// TODO generalise this later
class Explode extends Animation {
    // takes in an bitmap, split into certain number of square and move them into different direction
    var original: h2d.Bitmap;
    var animations: Array<Animation>;
    var started: Bool;
    var spritebatch: h2d.SpriteBatch;

    public function new(bitmap: h2d.Bitmap) {
        super();
        this.original = bitmap;
        this.started = false;
        this.animations = [];
        this.spritebatch = new h2d.SpriteBatch(bitmap.tile);
    }

    static final Split = 8;
    static final ExplodeDuration = .7;
    static final Deviation = 32;

    var timeElapsed: Float = 0.;

    override public function isDone(): Bool {
        return this.timeElapsed >= ExplodeDuration;
    }

    override public function update(dt: Float) {
        if (this.isDone()) return;
        if (!started) {
            var width = this.original.tile.width / Split;
            var height = this.original.tile.height / Split;
            for (x in 0...Split) {
                for (y in 0...Split) {
                    var t = this.original.tile.sub(x * width, y * height, width, height);
                    var b = this.spritebatch.alloc(t);
                    b.x = this.original.x + x * width;
                    b.y = this.original.y + y * height;
                    b.alpha = this.original.alpha;
                    var xMove = Random.int(-100, 100) / 50.0 * Deviation;
                    var yMove = Random.int(-100, 100) / 50.0 * Deviation;
                    this.animations.push(new MoveBySpeedByDuration(new WrappedBatchElement(b),
                        ExplodeDuration, [xMove, yMove]));
                    this.animations.push(new AlphaTo(new WrappedBatchElement(b), 0.0, 0.5 / ExplodeDuration));
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
