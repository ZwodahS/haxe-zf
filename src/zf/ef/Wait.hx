package zf.ef;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Wait extends Effect {
	@:dispose var elapsed: Float = 0;
	@:dispose var duration: Float = 0;

	function new() {
		super();
	}

	override function update(dt: Float): Bool {
		this.elapsed += dt;
		return this.duration <= elapsed;
	}

	override function restart() {
		this.elapsed = 0;
	}

	override public function clone(): Wait {
		return Wait.alloc(this.duration);
	}

	public static function alloc(duration: Float = 0): Wait {
		final wait = Wait.__alloc__();

		wait.duration = duration;

		return wait;
	}
}
