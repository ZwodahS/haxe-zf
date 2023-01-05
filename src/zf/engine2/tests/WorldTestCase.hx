package zf.engine2.tests;

import zf.tests.TestCase;

/**
	@stage:unstable

	Provide a generic TestCase to handle test cases with "engine2.World"
**/
class WorldTestCase extends TestCase {
	/**
		store the world object.

		Wed 12:00:26 04 Jan 2023
		This is stored as __world__ as there will be a specialised WorldTestCase in each game to provide
		the actual World object specific to the game.
	**/
	var __world__: zf.engine2.World;

	public function new(testId: String, name: String, world: World) {
		super(testId, name);
		this.__world__ = world;
	}

	override public function update(dt: Float) {
		super.update(dt);
		this.__world__.update(dt);
	}

	override public function onEvent(event: hxd.Event) {
		super.onEvent(event);
		this.__world__.onEvent(event);
	}

	override public function shouldRunNext(): Bool {
		if (super.shouldRunNext() == false) return false;
		return true;
	}

	/**
		Denote if the world is blocking.

		By default it checks for if __world__ default updater has any func running.
		Can be overriden to provide custom functionality.
	**/
	public function isWorldBlocking(): Bool {
		return this.__world__.updater.count != 0;
	}
}

/**
	Wed 11:49:54 04 Jan 2023 Start of tests module
**/
