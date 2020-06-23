
package common;
/**
  Parent Game.hx


  provide screen transition
**/

enum ScreenState {
    Exiting;
    Entering;
    Ready;
}

class Game extends hxd.App {

    var framerate: h2d.Text;
    var console: h2d.Console;

    override function init() {
        // add event handler
        this.s2d.addEventListener(this.onEvent);

#if debug
        this.setupConsole();
        this.setupFramerate();
#end
        this.screenState = Ready;
    }

#if debug
    function setupFramerate() {
        var font: h2d.Font = hxd.res.DefaultFont.get().clone();
        font.resizeTo(24);

        this.framerate = new h2d.Text(font);
        framerate.textAlign = Right;
        framerate.x = hxd.Window.getInstance().width - 10;

        this.s2d.add(this.framerate, 0);
        framerate.visible = false;
    }

    function setupConsole() {
        var font = hxd.res.DefaultFont.get().clone();
        font.resizeTo(12);

        this.console = new h2d.Console(font);
        this.s2d.add(this.console, 10);

        this.console.addCommand("getWindowSize", "get the window size", [], function() {
            var window = hxd.Window.getInstance();
            this.console.log('Window Size: ${window.width},${window.height}');
        });

        this.console.addCommand("printString", "print a string",
            [{"name": "string", "t": h2d.Console.ConsoleArg.AString},], function(string) {
                this.console.log(string);
        });

        this.console.addCommand("framerate", "toggle framerate", [], function() {
            this.framerate.visible = !this.framerate.visible;
        });
        this.console.addAlias("fr", "framerate");
    }
#end

    override function update(dt: Float) {
        if (this.currentScreen != null) this.currentScreen.update(dt);
        if (this.incomingScreen != null) this.incomingScreen.update(dt);
        if (this.outgoingScreen != null) this.outgoingScreen.update(dt);
#if debug
        this.framerate.text = '${common.MathUtils.round(1 / dt, 1)}';
#end
        if (this.screenState == Exiting) {
            if (outgoingScreen.doneExiting()) {
                this.s2d.removeChild(this.outgoingScreen);
                this.outgoingScreen.destroy();
                this.outgoingScreen = null;
                if (incomingScreen != null) {
                    beginIncommingScreen();
                } else {
                    this.screenState = Ready;
                }
            }
        } else if(this.screenState == Entering) {
            if (incomingScreen.doneEntering()) {
                this.screenState = Ready;
                this.currentScreen = this.incomingScreen;
                this.incomingScreen = null;
            }
        }
    }

    function onEvent(event: hxd.Event) {
        if (this.currentScreen != null) this.currentScreen.onEvent(event);
    }

    override function render(engine: h3d.Engine) {
        this.s2d.render(engine);
    }

    /** Screen management code **/
    var currentScreen: common.Screen;
    var incomingScreen: common.Screen;
    var outgoingScreen: common.Screen;

    var screenState: ScreenState;

    function switchScreen(screen: common.Screen) {
        if (this.currentScreen == screen) return;
        if (this.currentScreen != null) this.outgoingScreen = this.currentScreen;
        this.currentScreen = null;
        this.incomingScreen = screen;

        if (this.outgoingScreen != null) {
            this.screenState = Exiting;
            this.outgoingScreen.beginScreenExit();
        } else if (this.incomingScreen != null) {
            beginIncommingScreen();
        }
    }

    function beginIncommingScreen() {
        this.screenState = Entering;
        this.incomingScreen.beginScreenEnter();
        this.s2d.add(this.incomingScreen, 0);
    }

    function screenExited(screen: common.Screen) {}
    function screenEntered(screen: common.Screen) {}

}
