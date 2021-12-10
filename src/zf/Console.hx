package zf;

class Console extends h2d.Console {
	var g: Game;

	var subcommandSuggestions: Map<String, Array<String>->String>;

	public function new(font, ?parent, g: Game) {
		this.g = g;
		this.subcommandSuggestions = new Map<String, Array<String>->String>();
		super(font, parent);
	}

	override public function show() {
		super.show();
#if debug
		@:privateAccess g.consoleBg.visible = true;
#end
	}

	override public function hide() {
		super.hide();
#if debug
		@:privateAccess g.consoleBg.visible = false;
#end
	}

	// perhaps upgrade console and put these into add Command instead ?
	override function getCommandSuggestion(cmd: String): String {
		// handle prefix blocking the command suggestion
		var havePrefix = false;
		var prefix = "";
		if (cmd.charCodeAt(0) == this.shortKeyChar) {
			havePrefix = true;
			prefix = cmd.charAt(0);
			cmd = cmd.substr(1);
		}
		final cmds = cmd.split(" ");
		if (cmds.length == 0) return "";
		if (cmds.length == 1) {
			final suggestion = super.getCommandSuggestion(cmd);
			if (suggestion == "") return "";
			return prefix + suggestion;
		} else {
			final suggestion = getSubcommandSuggestion(cmds[0], cmds.slice(1));
			if (suggestion == "") return "";
			return prefix + cmds[0] + " " + suggestion;
		}
		// call parent if the length is 1
	}

	function getSubcommandSuggestion(cmd: String, rest: Array<String>): String {
		if (this.aliases.exists(cmd)) cmd = this.aliases.get(cmd);
		final func = this.subcommandSuggestions[cmd];
		if (func == null) return "";
		return func(rest);
	}

	public function addSubcommandSuggestion(cmd: String, func: Array<String>->String) {
		this.subcommandSuggestions[cmd] = func;
	}

	public function addSubcommandSuggestionList(cmd: String, stringList: Array<String>) {
		this.subcommandSuggestions[cmd] = simpleSubstringFind.bind(stringList);
	}

	public static function simpleSubstringFind(stringList: Array<String>, args: Array<String>) {
		if (args.length != 1) return "";
		final arg = args[0];
		var closestCommand = "";
		for (command in stringList) {
			if (command.indexOf(arg) == 0) {
				if (closestCommand == "" || closestCommand.length > command.length) {
					closestCommand = command;
				}
			}
		}
		return closestCommand;
	}
}
