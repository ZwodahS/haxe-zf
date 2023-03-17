package zf.debug;

import zf.h2d.HtmlText;
import zf.ui.ScrollArea;

import hxd.Key;

/**
	Rewrite Console to do the same thing but as part of the DebugOverlay
**/
/**
	The console argument type.
**/
enum ConsoleArg {
	/**
		An integer parameter.
	**/
	AInt;

	/**
		A floating-point parameter.
	**/
	AFloat;

	/**
		A text string parameter.
	**/
	AString;

	/**
		A boolean parameter. Can be `true`, `false`, `1` or `0`.
	**/
	ABool;

	/**
		A text string parameter with limitation to only accept the specified list values.
	**/
	AEnum(values: Array<String>);
}

/**
	A descriptor for an argument of a console command.
**/
typedef ConsoleArgDesc = {
	/**
		A human-readable argument name.
	**/
	name: String,

	/**
		The type of the argument.
	**/
	t: ConsoleArg,

	/**
		When set, argument is considered optional and command callback will receive `null` if argument was omitted.
		Inserting optional arguments between non-optional arguments leads to an undefined behavior.
	**/
	?opt: Bool,
	/**
		When provided, suggestions will be provided for the args of the command.
		the first arg to the function is the full tokenized command
		the second arg to the function the current arg

		the function should return the best suggestion for the current arg only.
	**/
	?argSuggestions: (Array<String>, String) -> String,
}

class OverlayConsole extends h2d.Object {
	var game: Game;

	public var conf = {
		alpha: 0.5,
		paddingX: 2,
		bgColor: 0xff111012,
		width: 0, // set by DebugOverlay
		height: 0, // set by DebugOverlay
		inputHeight: 0,
		textColor: 0xfffffbe5,
		errorColor: 0xffe67a73,
	}

	var input: h2d.TextInput;
	var inputBg: h2d.Bitmap;
	var hintText: h2d.Text;
	var font: h2d.Font;
	var previousCommands: Array<String>;
	var commandIndex: Int = -1;

	var logText: HtmlText;
	var scrollArea: ScrollArea;

	// cache the current command while pressing up and down
	var cacheCommand: String;

	var dirty = false;

	public function new(font: h2d.Font, game: Game) {
		super();
		this.game = game;
		this.font = font;
		this.previousCommands = [];
	}

	public function init() {
		final bg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		bg.width = this.conf.width;
		bg.height = this.conf.height;
		bg.alpha = this.conf.alpha;
		this.addChild(bg);

		this.inputBg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		this.inputBg.width = this.conf.width;
		this.inputBg.height = this.conf.inputHeight;
		final inputInteractive = new zf.h2d.Interactive(this.conf.width, this.conf.height);
		this.inputBg.addChild(inputInteractive);
		inputInteractive.onClick = (_) -> {
			this.input.focus();
		}
		this.input = new h2d.TextInput(this.font);
		this.input.textColor = this.conf.textColor;
		this.addChild(this.inputBg);
		this.addChild(this.input);
		this.input.text = '';
		this.input.onKeyDown = handleKey;
		this.input.onChange = handleCmdChange;
		this.inputBg.x = 0;
		this.inputBg.y = this.conf.height - this.conf.inputHeight;
		this.input.x = this.conf.paddingX;
		this.input.y = this.conf.height - this.conf.inputHeight;

		this.hintText = new h2d.Text(this.font);
		this.hintText.x = this.conf.paddingX;
		this.hintText.y = this.conf.height - this.conf.inputHeight;
		this.hintText.textColor = this.conf.textColor;
		this.hintText.alpha = .5;
		this.addChild(this.hintText);

		this.logText = new HtmlText(this.font);
		this.logText.x = this.conf.paddingX;
		this.scrollArea = ScrollArea.make({
			object: this.logText,
			size: [this.conf.width, this.conf.height - this.conf.inputHeight - 2],
			cursorColor: this.conf.textColor,
		});
		this.addChild(this.scrollArea);

		resetCommands();
	}

	function handleKey(e: hxd.Event) {
		if (this.visible == false) return;
		switch (e.keyCode) {
			case Key.ENTER, Key.NUMPAD_ENTER:
				final cmd = this.input.text;
				this.input.text = "";
				this.hintText.text = "";

				handleCommand(cmd);
				e.cancel = true;
				return;
			case Key.TAB:
				if (hintText.text != "") {
					this.input.text = hintText.text + " ";
					this.input.cursorIndex = this.input.text.length;
				}
			case Key.UP:
				if (this.previousCommands.length == 0 || this.commandIndex == 0) return;
				if (this.commandIndex == -1) {
					this.cacheCommand = this.input.text;
					this.commandIndex = this.previousCommands.length - 1;
				} else {
					this.commandIndex -= 1;
				}
				this.input.text = this.previousCommands[this.commandIndex];
				this.input.cursorIndex = this.input.text.length;
			case Key.DOWN:
				if (this.commandIndex == -1) return;
				if (this.commandIndex == this.previousCommands.length - 1) {
					this.input.text = this.cacheCommand == null ? "" : this.cacheCommand;
					this.input.cursorIndex = this.input.text.length;
					this.commandIndex = -1;
					return;
				}
				this.commandIndex += 1;
				this.input.text = this.previousCommands[this.commandIndex];
				this.input.cursorIndex = this.input.text.length;

			case Key.C:
				if (Key.isDown(Key.CTRL) == true) clearCommand();

			case Key.W:
				if (Key.isDown(Key.CTRL) == true) removeWord();
		}
	}

	function handleCmdChange() {
		this.hintText.visible = true;
		this.hintText.text = getCommandSuggestion(this.input.text);
	}

	function getCommandSuggestion(cmd: String): String {
		if (cmd == "") {
			return "";
		}
		var lowCmd = cmd.toLowerCase();

		var tokenizedCmds = splitCommands(cmd);
		if (tokenizedCmds == null) return ""; // badly formatted string
		if (tokenizedCmds.length == 1) {
			// if there is only one command, we will default to command suggestions
			var closestCommand = "";
			var commandNames = commands.keys();
			for (command in commandNames) {
				if (command.toLowerCase().indexOf(lowCmd) == 0) {
					if (closestCommand == "" || closestCommand.length > command.length) {
						closestCommand = command;
					}
				}
			}

			if (aliases.exists(cmd)) closestCommand = cmd;
			return closestCommand;
		} else {
			// there must be an exact matched commands or alias for commands args suggestions to work.
			var commandName = tokenizedCmds[0];
			// check for aliases
			if (this.aliases.exists(commandName)) commandName = this.aliases.get(commandName);
			// if no existing command, exit
			if (this.commands[commandName] == null) return "";
			// we will only provide completion for the last arg
			var lastArg = tokenizedCmds[tokenizedCmds.length - 1];
			var lastArgIndex = tokenizedCmds.length - 2;
			var command = this.commands[commandName];
			// if the args exceed the command's args, we provide no suggestion
			if (lastArgIndex >= command.args.length) return "";
			// if the arg does not have suggestions we will also provide no suggestion
			if (command.args[lastArgIndex] == null) return "";
			// if there is no suggestion, we will also return
			if (command.args[lastArgIndex].argSuggestions == null) return "";
			// call the function to get the suggestion
			var suggestion = command.args[lastArgIndex].argSuggestions(tokenizedCmds, lastArg);
			// if no suggestion, we will return no suggestion
			if (suggestion == null) return "";
			// reconstruct the command
			var commandBuilder: Array<String> = [];
			commandBuilder.push(tokenizedCmds[0]);
			for (ind in 1...tokenizedCmds.length - 1) {
				commandBuilder.push(tokenizedCmds[ind]);
			}
			commandBuilder.push(suggestion);
			return commandBuilder.join(" ");
		}
	}

	function handleCommand(command: String) {
		command = StringTools.trim(command);
		if (command == "") return;

		this.previousCommands.push(command);
		this.commandIndex = -1;

		var args = splitCommands(command);
		if (args == null) {
			log('Bad formated string', this.conf.errorColor);
			return;
		}

		var cmdName = args[0];
		if (aliases.exists(cmdName)) cmdName = aliases.get(cmdName);
		var cmd = commands.get(cmdName);
		if (cmd == null) {
			log('Unknown command "${cmdName}"', this.conf.errorColor);
			return;
		}

		var vargs = new Array<Dynamic>();
		for (i in 0...cmd.args.length) {
			var a = cmd.args[i];
			var v = args[i + 1];
			if (v == null) {
				if (a.opt) {
					vargs.push(null);
					continue;
				}
				log('Missing argument ${a.name}', this.conf.errorColor);
				return;
			}
			switch (a.t) {
				case AInt:
					var i = Std.parseInt(v);
					if (i == null) {
						log('$v should be Int for argument ${a.name}', this.conf.errorColor);
						return;
					}
					vargs.push(i);
				case AFloat:
					var f = Std.parseFloat(v);
					if (Math.isNaN(f)) {
						log('$v should be Float for argument ${a.name}', this.conf.errorColor);
						return;
					}
					vargs.push(f);
				case ABool:
					switch (v) {
						case "true", "1": vargs.push(true);
						case "false", "0": vargs.push(false);
						default:
							log('$v should be Bool for argument ${a.name}', this.conf.errorColor);
							return;
					}
				case AString:
					// if we take a single string, let's pass the whole args (allows spaces)
					vargs.push(cmd.args.length == 1 ? StringTools.trim(command.substr(args[0].length)) : v);
				case AEnum(values):
					var found = false;
					for (v2 in values) if (v == v2) {
						found = true;
						vargs.push(v2);
					}
					if (!found) {
						log('$v should be [${values.join("|")}] for argument ${a.name}', this.conf.errorColor);
						return;
					}
			}
		}

		doCall(cmd.callb, vargs);
	}

	function splitCommands(command: String): Array<String> {
		var args = [];
		var c = '';
		var i = 0;

		function readString(endChar: String) {
			var string = '';

			while (i < command.length) {
				c = command.charAt(++i);
				if (c == endChar) {
					++i;
					return string;
				}
				string += c;
			}

			return null;
		}

		inline function skipSpace() {
			c = command.charAt(i);
			while (c == ' ' || c == '\t') {
				c = command.charAt(++i);
			}
			--i;
		}

		var last = '';
		while (i < command.length) {
			c = command.charAt(i);

			switch (c) {
				case ' ' | '\t':
					skipSpace();

					args.push(last);
					last = '';
				case "'" | '"':
					var string = readString(c);
					if (string == null) {
						return null;
					}

					args.push(string);
					last = '';

					skipSpace();
				default:
					last += c;
			}

			++i;
		}
		args.push(last);
		return args;
	}

	// ---- Handle Commands Adding ---- //
	var commands: Map<String, {help: String, args: Array<ConsoleArgDesc>, callb: Dynamic}>;
	var aliases: Map<String, String>;

	/**
		Reset all commands and aliases to default
	**/
	public function resetCommands() {
		this.commands = [];
		this.aliases = [];
		addCommand("help", "Show help", [{name: "command", t: AString, opt: true}], showHelp);
		addCommand("clear", "Clear console", [], clearConsole);
		addAlias("?", "help");
	}

	/**
		Add a new command to console.
		@param name Command name.
		@param help Optional command description text.
		@param args An array of command arguments.
		@param callb The callback method taking the arguments listed in `args`.
	**/
	public function addCommand(name: String, ?help: String, args: Array<ConsoleArgDesc>, callb: Dynamic) {
		commands.set(name, {help: help == null ? "" : help, args: args, callb: callb});
	}

	/**
		Add an alias to an existing command.
		@param name Command alias.
		@param command Full command name to alias.
	**/
	public function addAlias(name: String, command: String) {
		aliases.set(name, command);
	}

	// ---- Help ---- //
	function showHelp(?command: String) {
		var all;
		if (command == null) {
			all = Lambda.array({iterator: function() return commands.keys()});
			all.sort(Reflect.compare);
			all.remove("help");
			all.push("help");
		} else {
			if (aliases.exists(command)) command = aliases.get(command);
			if (!commands.exists(command)) throw 'Command not found "$command"';
			all = [command];
		}
		for (cmdName in all) {
			final c = commands.get(cmdName);
			var str = cmdName;
			for (a in aliases.keys()) if (aliases.get(a) == cmdName) str += "|" + a;
			for (a in c.args) {
				var astr = a.name;
				switch (a.t) {
					case AInt, AFloat:
						astr += ":" + a.t.getName().substr(1);
					case AString:
					// nothing
					case AEnum(values):
						astr += "=" + values.join("|");
					case ABool:
						astr += "=0|1";
				}
				str += " " + (a.opt ? "[" + astr + "]" : astr);
			}
			if (c.help != "") str += " : " + c.help;
			log(str);
		}
		log('');
	}

	function doCall(callb: Dynamic, vargs: Array<Dynamic>) {
		try {
			Reflect.callMethod(null, callb, vargs);
		} catch (e: String) {
			log('ERROR ${e}', this.conf.errorColor);
		}
	}

	// ---- Logging ---- //

	/**
		Print to the console log.
		@param text The text to show in the log message.
		@param color Optional custom text color.
	**/
	public function log(text: String, ?color: Color) {
		if (color == null) color = this.conf.textColor;
		this.logText.text = (this.logText.text
			+ '<font color="#${StringTools.hex(color & 0xFFFFFF, 6)}">${StringTools.htmlEscape(text)}</font><br/>');
		this.dirty = true;
	}

	override function sync(ctx: h2d.RenderContext) {
		if (this.dirty == true) {
			this.scrollArea.onObjectUpdated();
			this.scrollArea.toBottom();
			this.dirty = false;
		}
		super.sync(ctx);
	}

	public function clearConsole() {
		this.logText.text = '';
		this.scrollArea.onObjectUpdated();
		this.scrollArea.toBottom();
	}

	public function clearCommand() {
		this.input.text = '';
		handleCmdChange();
	}

	public function removeWord() {
		var index = this.input.text.lastIndexOf(" ");
		if (index == -1) index = 0;
		this.input.text = this.input.text.substr(0, index);
		handleCmdChange();
	}

	// ---- Event ---- //

	public function onShow() {
		this.input.focus();
	}
}
/**
	Fri 12:13:02 17 Mar 2023
	Fork this from Console
**/
