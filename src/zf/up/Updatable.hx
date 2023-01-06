package zf.up;

/**
	@stage:stable

	See zf.up.Updater for detailed documentation
**/
typedef Updatable = {
	/**
		called the first time the update is added to the updater
	**/
	public function init(u: Updater): Void;

	/**
		called on each frame of the update
	**/
	public function update(dt: Float): Void;

	/**
		return true if the update is done, false otherwise
	**/
	public function isDone(): Bool;

	/**
		called when the update finishes.
	**/
	public function onFinish(): Void;

	/**
		called when the update is removed from the updater
	**/
	public function onRemoved(): Void;
}
