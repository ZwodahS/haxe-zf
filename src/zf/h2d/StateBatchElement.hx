package zf.h2d;

/**
	@stage:stable

	StateBatchElement does the same thing as StateObject, except as a BatchElement.
**/
class StateBatchElement extends h2d.SpriteBatch.BatchElement {
	/**
		Tue 12:15:41 04 Aug 2020
		For now we will deal with each state being a Tile.
		At some time we will have to handle animation.
		In StateObject, we uses Anim. In this case, we need the same logic as Anim, and
		override the update function of BatchElement to handle that.
	**/
	var states: Map<String, h2d.Tile>;

	public var state(default, set): String;

	public function new() {
		super(null);
		this.states = new Map<String, h2d.Tile>();
	}

	public function set_state(s: String): String {
		if (this.state == s) return this.state;
		this.state = s;
		this.t = this.states[state];
		this.visible = this.t != null;
		return this.state;
	}

	public function addState(s: String, t: h2d.Tile) {
		if (this.states[s] != null) return;
		this.states[s] = t;
	}

	public function removeState(s: String) {
		if (this.state == s) {
			this.t = null;
			this.visible = false;
		}
		this.states.remove(s);
	}
}
