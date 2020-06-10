package common;

class TimerCircle extends h2d.Layers {
    public var maxTime(default, set): Float;
    public var autoReset(default, set): Bool;
    public var time(default, set): Float;

    var radius: Float;

    var g: h2d.Graphics;

    public var onComplete: Void->Void;

    public var complete(default, null): Bool;
    public var fillColor(default, set): Int;
    public var lineColor(default, set): Int;
    public var backgroundColor(default, set): Null<Int>;

    public function new(maxTime: Float = 1, autoReset: Bool = true, radius: Float = 1, fillColor: Int = 0xFF0000, lineColor: Int = 0xFFFFFF) {
        super();
        this.maxTime = maxTime;
        this.autoReset = autoReset;
        this.radius = radius;
        this.g = new h2d.Graphics(this);
        this.complete = false;
        this.time = 0;
        this.fillColor = fillColor;
        this.lineColor = lineColor;
        this.backgroundColor = null;
        redraw();
    }

    public function set_maxTime(t: Float): Float {
        this.maxTime = t;
        redraw();
        return t;
    }

    public function set_autoReset(b: Bool): Bool {
        this.autoReset = b;
        redraw();
        return b;
    }

    public function set_fillColor(v: Int): Int {
        this.fillColor = v;
        redraw();
        return this.fillColor;
    }

    public function set_lineColor(v: Int): Int {
        this.lineColor = v;
        redraw();
        return this.lineColor;
    }

    public function set_backgroundColor(v: Null<Int>): Null<Int> {
        this.backgroundColor = v;
        redraw();
        return this.backgroundColor;
    }

    public function set_time(t: Float): Float {
        this.time = t;
        if (this.time >= this.maxTime && !this.complete) {
            if (this.autoReset) {
                this.reset();
            } else {
                this.complete = true;
            }
            if (this.onComplete != null) this.onComplete();
        }
        redraw();
        return this.time;
    }

    override function onAdd() {
        super.onAdd();
        this.redraw();
    }

    public function reset() {
        this.complete = false;
        this.time = this.time % this.maxTime;
    }

    function redraw() {
        if (this.g == null) return;
        this.g.clear();
        if (this.backgroundColor == null) {
            this.g.beginFill(0x000000, 0);
        } else {
            this.g.beginFill(this.backgroundColor, 1.0);
        }
        this.g.lineStyle(1, this.lineColor, 1);
        this.g.drawCircle(0, 0, radius, 0);
        this.g.endFill();

        this.g.lineStyle(1, 0x000000, 0);
        this.g.beginFill(this.fillColor);
        this.g.drawPie(0, 0, radius, 1.5 * Math.PI, this.time / this.maxTime * 2 * Math.PI);
        this.g.endFill();
    }
}
