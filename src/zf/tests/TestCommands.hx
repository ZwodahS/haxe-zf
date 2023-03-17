package zf.tests;

import zf.debug.OverlayConsole.ConsoleArg;

/**
	@stage:unstable

	Provide commands that can be added to the game to run tests
**/
class TestCommands {
	public static var makeScreen: Void->TestScreen = () -> {
		return new TestScreen();
	}

	public static function setupCommands(game: Game, console: zf.debug.OverlayConsole, testNames: Array<String>) {
		testNames.push("--all");
		// ---- Test Related commands ----//
		{
			console.addCommand("test.run", "run a specific test", [
				{
					"name": "testName",
					"t": ConsoleArg.AString,
					"argSuggestions": function(tokenized: Array<String>, arg: String) {
						return zf.StringUtils.findClosestMatch(testNames, arg);
					}
				}
			], function(testName: String) {
				try {
					var screen: TestScreen = null;
					if (Std.isOfType(game.currentScreen, TestScreen)) {
						screen = cast(game.currentScreen, TestScreen);
					} else {
						screen = makeScreen();
						game.switchScreen(screen);
					}
					screen.runCommand([testName]);
				} catch (e) {
					Logger.exception(e);
				}
			});
		}
		{
			console.addCommand("test.concurrent", "set the number of concurrent runner", [
				{
					"name": "count",
					"t": ConsoleArg.AInt,
				}
			], function(count: Int) {
				try {
					var screen: TestScreen = null;
					if (Std.isOfType(game.currentScreen, TestScreen) == false) return;
					screen = cast(game.currentScreen, TestScreen);
					screen.concurrent = count;
				} catch (e) {
					Logger.exception(e);
				}
			});
		}
		{
			console.addCommand("test.list", "List all the test case name", [], function() {
				for (testName in testNames) {
					console.log(testName);
				}
			});
		}
		{
			console.addCommand("test.screen", "Open Test Screen", [], function() {
				try {
					var screen: TestScreen = null;
					if (Std.isOfType(game.currentScreen, TestScreen)) {
						screen = cast(game.currentScreen, TestScreen);
					} else {
						screen = makeScreen();
						game.switchScreen(screen);
					}
				} catch (e) {
					Logger.exception(e);
				}
			});
		}
	}
}

/**
	Wed 11:49:54 04 Jan 2023 Start of tests module
**/
