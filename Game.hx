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

#if debug
@:access(common.Game)
class Console extends h2d.Console {
    var g: Game;

    public function new(font, ?parent, g: Game) {
        this.g = g;
        super(font, parent);
    }

    override public function show() {
        super.show();
        g.consoleBg.visible = true;
    }

    override public function hide() {
        super.hide();
        g.consoleBg.visible = false;
    }
}
#end

class Game extends hxd.App {
    var framerate: h2d.Text;
    var drawCalls: h2d.Text;

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
    var console: h2d.Console;
    var consoleBg: h2d.Bitmap;

    function setupFramerate() {
        var font: h2d.Font = hxd.res.DefaultFont.get().clone();
        font.resizeTo(12);

        this.s2d.add(this.framerate = new h2d.Text(font), 100);
        this.framerate.textAlign = Left;
        this.framerate.x = 0;
        this.framerate.visible = false;

        this.s2d.add(this.drawCalls = new h2d.Text(font), 100);
        this.drawCalls.textAlign = Left;
        this.drawCalls.y = 16;
        this.drawCalls.visible = false;
    }

    function setupConsole() {
        var font = hxd.res.DefaultFont.get().clone();
        font.resizeTo(12);

        this.consoleBg = new h2d.Bitmap(h2d.Tile.fromColor(1, 1, 1, 0.5));
        this.consoleBg.tile.scaleToSize(s2d.width, s2d.height);
        this.consoleBg.visible = false;

        this.console = new Console(font, this);
        this.s2d.add(this.consoleBg, 9);
        this.s2d.add(console, 10);

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
            this.drawCalls.visible = !this.drawCalls.visible;
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
        } else if (this.screenState == Entering) {
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
#if debug
        var t0 = haxe.Timer.stamp();
#end
        this.s2d.render(engine);
#if debug
        var drawTime = '${common.Strings.formatFloat(haxe.Timer.stamp() - t0, 5)}s';
        this.drawCalls.text = 'draw: ${engine.drawCalls} (${drawTime})';
#end
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
