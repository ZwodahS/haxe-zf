package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;

using haxe.macro.Tools;

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

	@handle("XMessage", 0)
	function handleMessage(m: XMessage) {
		// ...
	}

	and we can just call `setupMessages in init`

	function init(world) {
		setupMessages(world.dispatcher);
	}
**/
class Messages {
	public function new() {}

	function _build() {
		final fields = Context.getBuildFields();
		final className = Context.getLocalClass();
		final type = Context.getLocalType();

		final localClass = type.getClass();
		final typePath = {
			name: localClass.name,
			pack: localClass.pack
		}

		// collect all the handlers via @handleMessage
		var handlers: Array<{field: haxe.macro.Field, message: String, priority: Int}> = [];

		for (f in fields) {
			if (f.meta.length == 0) continue;
			for (m in f.meta) {
				if (m.name == "handleMessage") {
					if (m.params.length != 2) {
						Context.info("[Warn] handleMessage requires 2 arguments - [messageClass, priority]", f.pos);
						continue;
					}

					var klass = null;
					try {
						var type = Context.getType(m.params[0].getValue());
						klass = type.getClass();
					} catch (e) {
						Context.info('[Warn] handleMessage unable to find class: ${m.params[0].getValue()}', f.pos);
						continue;
					}

					handlers.push({field: f, message: m.params[0].getValue(), priority: m.params[1].getValue()});
				}
			}
		}

		{ // set up all the listen
			final exprs: Array<Expr> = [];

			for (handler in handlers) {
				final field = handler.field.name;
				final messageName = handler.message;
				final priority = handler.priority;
				exprs.push(macro {
					dispatcher.listen($i{messageName}.MessageType, (message: zf.Message) -> {
						this.$field(cast message);
					}, $v{priority});
				});
			}

			fields.push({
				name: "setupMessages",
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name: "dispatcher", type: TPath({name: "MessageDispatcherI", pack: ["zf"]})}],
					expr: macro $a{exprs},
					ret: macro : Void,
				}),
				access: [],
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
