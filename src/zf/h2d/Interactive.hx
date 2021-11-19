package zf.h2d;

/**
	Override h2d.Interactive to provide a few more functionalities.
**/
class Interactive extends h2d.Interactive {
	override public function onRemove() {
		super.onRemove();
		this.dyOnRemove();
	}

	dynamic public function dyOnRemove() {}
}
