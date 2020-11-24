package zf.h2d;

/**
    StateObject are used to store graphic assets into objects that have state.
    For example, a platformer can use it to store jumping state, idle state, attack state etc.

    [Wed Jun 17 11:04:35 2020]
    Some assumptions when using this.

    1.
    All the anim/bitmap have their x, y, dx, dy before adding into the state.

    2.
    State Object do not manage the direction that the object is currently facing, but only provide a flipX/flipY
    function that flips all the tiles in the state object.

    Note on using:

    1. if state is set to something that is not present in the configured state, then nothing will be shown.
    2. if there is a state change, the frame of the incoming state will be set to 0.
    3. when the new state is the same as the current state, nothing happens.
**/
class StateObject extends h2d.Layers {
    var tiles: List<h2d.Tile>;
    var states: Map<String, h2d.Object>;

    public var state(default, set): String;

    public var layer: h2d.Layers;

    public function new(?layer: h2d.Layers) {
        /**
            to use StateObject like component rather than a layer, then just provide it with an optional argument layer
        **/
        super();

        this.tiles = new List<h2d.Tile>();
        this.states = new Map<String, h2d.Object>();
        this.state = "";
        this.layer = layer == null ? this : layer;
    }

    public function set_state(s: String): String {
        if (this.state == s) return this.state;
        if (states[this.state] != null) this.states[this.state].visible = false;
        this.state = s;
        if (states[this.state] != null) {
            this.states[this.state].visible = true;
            if (Std.is(this.states[this.state], h2d.Anim)) {
                cast(this.states[this.state], h2d.Anim).currentFrame = 0.0;
            }
        }
        return this.state;
    }

    public function addState(s: String, ?anim: h2d.Anim, ?bitmap: h2d.Bitmap) {
        // if state already exist, then we don't do anything.
        if (this.states[s] != null) return;
        if (anim != null) this.addAnim(s, anim); else if (bitmap != null) addBitmap(s, bitmap);
    }

    function addBitmap(s: String, bitmap: h2d.Bitmap) {
        this.states[s] = bitmap;
        this.layer.add(bitmap, 0);
        this.tiles.push(bitmap.tile);
        bitmap.visible = this.state == s;
    }

    function addAnim(s: String, anim: h2d.Anim) {
        this.states[s] = anim;
        this.layer.add(anim, 0);
        for (f in anim.frames) {
            this.tiles.push(f);
        }
        anim.visible = this.state == s;
    }

    public function removeState(s: String): h2d.Object {
        if (this.states[s] == null) return null;
        var old = this.states[s];
        this.states.remove(s);
        if (Std.is(old, h2d.Anim)) {
            for (f in (cast(old, h2d.Anim).frames)) {
                this.tiles.remove(f);
            }
        } else if (Std.is(old, h2d.Bitmap)) {
            this.tiles.remove(cast(old, h2d.Bitmap).tile);
        }
        this.layer.removeChild(old);
        return old;
    }

    public function flipX() {
        for (t in this.tiles) t.flipX();
    }

    public function flipY() {
        for (t in this.tiles) t.flipY();
    }
}
