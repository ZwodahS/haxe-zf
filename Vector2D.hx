package common;

import haxe.ds.Vector;

typedef XY = {
    x: Int,
    y: Int
}

class Vector2DIteratorXY<T> {
    var data: Vector2D<T>;
    var currX: Int;
    var currY: Int;

    public function new(data: Vector2D<T>) {
        this.data = data;
        this.currX = 0;
        this.currY = 0;
    }

    public function hasNext(): Bool {
        return (this.currX < this.data.size.x && this.currY < this.data.size.y);
    }

    public function next(): {key: XY, value: T} {
        var returnValue = {
            key: {x: this.currX, y: this.currY},
            value: this.data.get(this.currX, this.currY)
        }
        if (this.currX == this.data.size.x - 1) {
            this.currX = 0;
            this.currY += 1;
        } else {
            this.currX += 1;
        }
        return returnValue;
    }
}

class Vector2DIteratorYX<T> {
    var data: Vector2D<T>;
    var currX: Int;
    var currY: Int;

    public function new(data: Vector2D<T>) {
        this.data = data;
        this.currX = 0;
        this.currY = 0;
    }

    public function hasNext(): Bool {
        return (this.currX < this.data.size.x && this.currY < this.data.size.y);
    }

    public function next(): {key: XY, value: T} {
        var returnValue = {
            key: {x: this.currX, y: this.currY},
            value: this.data.get(this.currX, this.currY)
        }
        if (this.currY == this.data.size.y - 1) {
            this.currY = 0;
            this.currX += 1;
        } else {
            this.currY += 1;
        }
        return returnValue;
    }
}

class Vector2D<T> {
    /**
        A 2x3 (width * height)
        [ 0, 1
          2, 3
          4, 5
          ]
        will be stored as [0, 1, 2, 3, 4, 5]
        There shouldn't be a need to know this when using this from outside.
    **/
    public var size(default, null): Point2i;

    var data: Vector<T>;
    var nullValue: T;

    public function toString(): String {
        var str = "";
        for (y in 0...this.size.y) {
            for (x in 0...this.size.x) {
                str += this.get(x, y) + " ";
            }
            str += "\n";
        }
        return str;
    }

    public function new(s: Point2i, nullValue: T, copy: Vector<T> = null) {
        this.size = s.copy();

        this.data = new Vector<T>(this.size.x * this.size.y);
        for (i in 0...data.length) {
            this.data[i] = nullValue;
        }
        if (copy != null) {
            for (i in 0...(hxd.Math.imin(this.data.length, copy.length))) {
                this.data[i] = copy[i];
            }
        }
    }

    inline public function get(x, y): T {
        var p = pos(x, y);
        return _inBound(p) ? data[p] : nullValue;
    }

    inline public function set(x, y, value: T) {
        var pos = pos(x, y);
        if (_inBound(pos)) this.data[pos] = value;
    }

    inline function pos(x: Int, y: Int): Int { // return -1 if out of bound
        return x + (y * size.x);
    }

    public function inBound(x: Int, y: Int): Bool {
        return _inBound(pos(x, y));
    }

    inline function _inBound(p: Int): Bool {
        return p >= 0 && p < data.length;
    }

    public function iterateXY(): Vector2DIteratorXY<T> {
        return new Vector2DIteratorXY<T>(this);
    }

    public function iterateYX(): Vector2DIteratorYX<T> {
        return new Vector2DIteratorYX<T>(this);
    }

    // https://stackoverflow.com/questions/18034805/rotate-mn-matrix-90-degrees
    public function rotateCCW() {
        var newLengthX = this.size.y;
        var newLengthY = this.size.x;
        var copy = new Vector<T>(this.data.length);
        var x1 = 0;
        var y1 = 0;
        var x0 = this.size.x - 1;
        while (x0 >= 0) {
            x1 = 0;
            for (y0 in 0...this.size.y) {
                copy[(y1 * newLengthX) + x1] = this.data[pos(x0, y0)];
                x1 += 1;
            }
            x0 -= 1;
            y1 += 1;
        }
        for (i in 0...data.length) {
            data[i] = copy[i];
        }
        this.size.x = newLengthX;
        this.size.y = newLengthY;
    }

    public function rotateCW() {
        var newLengthX = this.size.y;
        var newLengthY = this.size.x;
        var copy = new Vector<T>(this.data.length);
        var x1 = 0;
        var y1 = 0;
        var x0 = this.size.x - 1;
        for (x0 in 0...this.size.x) {
            x1 = newLengthX - 1;
            for (y0 in 0...this.size.y) {
                copy[(y1 * newLengthX) + x1] = this.data[pos(x0, y0)];
                x1 -= 1;
            }
            y1 += 1;
        }
        for (i in 0...data.length) {
            data[i] = copy[i];
        }
        this.size.x = newLengthX;
        this.size.y = newLengthY;
    }

    public function copy(): Vector2D<T> {
        return new Vector2D<T>(this.size, this.nullValue, this.data);
    }
}
