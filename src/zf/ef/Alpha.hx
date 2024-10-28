package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Alpha extends Effect {
	@:dispose var _delta: Float = 0;
	@:dispose var _changed: Float = 0;

	@:dispose public var alphaChange: Float = 0;
	@:dispose public var duration: Float = 0;

	override public function update(dt: Float): Bool {
		if (this._delta >= this.duration) return true;
		this._delta += dt;
		if (this._delta >= this.duration) this._delta = this.duration;

		this.object.alpha -= this._changed;
		this._changed = this._delta / this.duration * this.alphaChange;
		this.object.alpha += this._changed;

		return false;
	}

	override public function restart() {
		this._delta = 0;
		this._changed = 0;
	}

	override public function clone(): Alpha {
		final eff = Alpha.alloc();

		eff.alphaChange = this.alphaChange;
		eff.duration = this.duration;

		return eff;
	}

	public static function change(alphaChange: Float = 0, duration: Float = 0): Alpha {
		final alpha = Alpha.alloc();

		alpha.alphaChange = alphaChange;
		alpha.duration = duration;

		return alpha;
	}
}
