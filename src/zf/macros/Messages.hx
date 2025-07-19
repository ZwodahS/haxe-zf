package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;

using haxe.macro.Tools;

/**
	Provide a simple way to listen to messages from MessageDispatcher

	See #Motivation below

	# Usage

	1. Single message to single function
	@:handleMessage("XMessage", 0)
	function X(m: XMessage) {}

	2. Multiple message to single function
	@:handleMessages(["XMessage", "YMessage"], 0)
	function X() {}

	3. Calling setup
	setupMessages(dispatcher);

	4. Remove Listeners on dispose
	removeListeners(dispatcher);

	## dispose messages
	removeListeners(world.dispatcher);

	# Fields
	The macro will build the following fields and methods

	- __listeners__: Array<Int>
	- setupMessages(d: MessageDispatcher)
	- removeListeners(d: MessageDispatcher)

**/
class Messages {
	public function new() {}

	function _build() {
		final fields = Context.getBuildFields();
		final className = Context.getLocalClass();
		final type = Context.getLocalType();
		final localClass = type.getClass();
		final typePath = {name: localClass.name, pack: localClass.pack};
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		final parentHasSetup = (superClass != null && TypeTools.findField(superClass, "setupMessages") != null);
		final parentHasListeners = (superClass != null && TypeTools.findField(superClass, "__listeners__") != null);

		// collect all the handlers via @:handleMessage
		var handlers: Array<{field: haxe.macro.Field, message: String, priority: Int}> = [];

		for (f in fields) {
			if (f.name == "__listeners__") {
				Context.fatalError("[Error] __listeners__ cannot be defined by class.", f.pos);
			}
			if (f.meta.length == 0) continue;
			for (m in f.meta) {
				if (m.name == ":handleMessage") {
					if (m.params.length != 2) {
						Context.info("[Warn] @:handleMessage requires 2 arguments - [messageClassName, priority]",
							f.pos);
						continue;
					}

					var klass = null;
					try {
						var type = Context.getType(m.params[0].getValue());
						klass = type.getClass();
					} catch (e) {
						Context.info('[Warn] @:handleMessage unable to find class: ${m.params[0].getValue()}', f.pos);
						continue;
					}

					handlers.push({field: f, message: m.params[0].getValue(), priority: m.params[1].getValue()});
				} else if (m.name == ":handleMessages") {
					if (m.params.length != 2) {
						Context.info("[Warn] @:handleMessages requires 2 arguments - [<messageClassName>, priority]",
							f.pos);
						continue;
					}

					for (className in (m.params[0].getValue(): Array<String>)) {
						var klass = null;
						try {
							var type = Context.getType(className);
							klass = type.getClass();
						} catch (e) {
							Context.info('[Warn] @:handleMessage unable to find class: ${className}', f.pos);
							continue;
						}

						handlers.push({field: f, message: className, priority: m.params[1].getValue()});
					}
				}
			}
		}

		{ // set up all the listen
			var init: Array<Expr> = [];
			final exprs: Array<Expr> = [];
			final access = [];
			if (parentHasSetup == true) {
				access.push(AOverride);
			}

			if (parentHasListeners == false) {
				// build __listeners__
				fields.push({
					name: "__listeners__",
					pos: Context.currentPos(),
					kind: FVar(macro : Array<Int>, null),
					access: [],
					meta: [],
					doc: null,
				});

				fields.push({
					name: "__setupMessages__",
					pos: Context.currentPos(),
					kind: FVar(macro : Bool, null),
					access: [],
					meta: [],
					doc: null,
				});

				init.push(macro {
					this.__listeners__ = [];
				});
			}

			for (handler in handlers) {
				final field = handler.field.name;
				final args = Util.getFunctionArguments(handler.field.kind);
				final messageName = handler.message;
				final priority = handler.priority;
				if (args.length == 1) {
					exprs.push(macro {
						final id = dispatcher.listen($i{messageName}.MessageType, (message: zf.Message) -> {
							this.$field(cast message);
						}, $v{priority});
						this.__listeners__.push(id);
					});
				} else if (args.length == 0) {
					exprs.push(macro {
						final id = dispatcher.listen($i{messageName}.MessageType, (message: zf.Message) -> {
							this.$field();
						}, $v{priority});
						this.__listeners__.push(id);
					});
				} else {
					Context.fatalError("Message handlers must have 0 or 1 argument", handler.field.pos);
				}
			}

			var expr = null;
			if (parentHasSetup == true) {
				expr = macro {
					if (this.__setupMessages__ == true) {
						trace('[Messages] Double calling setupMessages in ' + $v{className.toString()} + '.', null);
						return;
					}
					super.setupMessages(dispatcher);
					$a{init} $a{exprs}
				}
			} else {
				expr = macro {
					if (this.__setupMessages__ == true) {
						trace('[Messages] Double calling setupMessages in ' + $v{className.toString()} + '.', null);
						return;
					}
					$a{init} $a{exprs} this.__setupMessages__ = true;
				}
			}

			fields.push({
				name: "setupMessages",
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name: "dispatcher", type: TPath({name: "MessageDispatcherI", pack: ["zf"]})}],
					expr: expr,
					ret: macro : Void,
				}),
				access: access,
				doc: null,
				meta: [],
			});

			fields.push({
				name: "removeListeners",
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name: "dispatcher", type: TPath({name: "MessageDispatcherI", pack: ["zf"]})}],
					expr: macro {
						for (id in this.__listeners__) {
							dispatcher.removeListener(id);
						}
						this.__listeners__.clear();
					},
					ret: macro : Void,
				}),
				access: access,
				doc: null,
				meta: [],
			});
		}

		return fields;
	}

	public static function build() {
		return new Messages()._build();
	}
}
#end

/**
	# Motivation
	Previously in most classes that listen to messages, there is a pattern of handling it in 2 parts

	The first part is to listen the messages
	```
	function init(world) {
		world.dispatcher.listen(Message.MessageType, (message: zf.Message) -> {
			handleMessage(cast message);
		}, 0);
		...
	}
	```

	The second part defines the message
	```
	function handleMessage(m: XMessage) {
		// ...
	}
	```

	Writing this is tedious, and prone to bugs sometimes. It also makes the init function really long and hard to read.
	This macro is to streamline that to

	@:handleMessage("XMessage", 0)
	function handleMessage(m: XMessage) {
		// ...
	}

	and we can just call `setupMessages in init`

	function init(world) {
		setupMessages(world.dispatcher);
	}

	Sometimes we also perform the same logic for multiple different messages
	For example, Recompute cache with something happen, often after different type of messages

	In this case, most of the time we don't need the message object

	To handle this we have

	@:handleMessages(["XMessage", "YMessage"], 0)

	Wed 14:34:40 21 Aug 2024
	rename @handleMessage -> @:handleMessage, @handleMessages -> @:handleMessages

	Thu 12:06:51 26 Jun 2025
	store listener id and add removeListeners method.
**/
