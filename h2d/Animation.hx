
package common.h2d;

import common.Updater;
import common.Point2f;

/**
  Animation provide the common "animation" for h2d.Objects
**/


class MoveToAnimation implements Updatable {

    var object: h2d.Object;
    var position: Point2f;
    var speed: Point2f;

    public function new(object: h2d.Object, position: Point2f, speeds: Point2f = null, speed: Float = 1) {
        this.object = object;
        this.position = position;
        if (speeds != null) {
            this.speed = speeds;
        } else {
            this.speed = [ speed, speed ];
        }
    }

    public function onStart() {}
    public function onDestroy() {}
    public function isDone() { return this.position == [ this.object.x, this.object.y ]; }
    public function update(dt: Float) {
        if (this.isDone()) { return; }

        if (this.object.x != this.position.x) {
            var direction = this.object.x > this.position.x ? -1 : 1;
            var moveX = this.speed.x * dt * direction;
            if (moveX < 0) {
                this.object.x = Math.max(this.object.x + moveX, this.position.x);
            } else {
                this.object.x = Math.min(this.object.x + moveX, this.position.x);
            }
        }

        if (this.object.y != this.position.y) {
            var direction = this.object.y > this.position.y ? -1 : 1;
            var moveY = this.speed.y * dt * direction;
            if (moveY < 0) {
                this.object.y = Math.max(this.object.y + moveY, this.position.y);
            } else {
                this.object.y = Math.min(this.object.y + moveY, this.position.y);
            }
        }

    }

}

class Animator extends common.Updater { // extends the Updater since most of it is the same

}

