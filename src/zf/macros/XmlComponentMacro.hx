package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using haxe.macro.Tools;

/**
	See zf.ui.builder.XmlComponent
**/
class XmlComponentMacro {
	public function new() {}

	public function buildClass() {
		final fields = Context.getBuildFields();

		var findChildVar: Array<{field: haxe.macro.Field, path: String}> = [];
		var exposeContext: Array<{field: haxe.macro.Field, name: String}> = [];
		for (f in fields) {
			if (f.meta.length == 0) continue;
			for (m in f.meta) {
				if (m.name == "findChild") {
					var path = f.name;
					if (m.params.length > 0) path = m.params[0].getValue();
					findChildVar.push({field: f, path: path});
				}
				if (m.name == "exposeContext") {
					var name = f.name;
					if (m.params.length > 0) name = m.params[0].getValue();
					exposeContext.push({field: f, name: name});
				}
			}
		}

		{ // ---- Bind variables ---- //
			var exprs: Array<Expr> = [];
			for (v in findChildVar) {
				final field = v.field.name;
				final path = v.path;
#if debug
				exprs.push(macro this.$field = cast _getObjectByName($v{path}));
#else
				exprs.push(macro this.$field = cast getObjectByName($v{path}));
#end
			}

#if debug
			fields.push({
				name: "_getObjectByName",
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name: "name", type: TPath({name: "String", pack: []})}],
					expr: macro {
						final object = getObjectByName(name);
						if (object == null) trace('fail to find child "${name}"');
						return object;
					},
					ret: macro : h2d.Object,
				}),
				access: [],
				doc: null,
				meta: [],
			});
#end

			fields.push({
				name: "_buildVariables",
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $a{exprs},
					ret: macro : Void,
				}),
				access: [AOverride],
				doc: null,
				meta: [],
			});
		}

		{ // ---- Bind Context ---- //
			final contextExprs: Array<Expr> = [];
			for (v in exposeContext) {
				final field = v.field.name;
				final name = v.name;
				contextExprs.push(macro this.__context__.$name = this.$field);
			}

			fields.push({
				name: "_initContext",
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $a{contextExprs},
					ret: macro : Void,
				}),
				access: [AOverride],
				doc: null,
				meta: [],
			});
		}

		return fields;
	}

	public static function build() {
		return new XmlComponentMacro().buildClass();
	}
}
#end
