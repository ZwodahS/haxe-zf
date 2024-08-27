package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.*;
import haxe.macro.Type.ClassType;

using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Tools;

/**
	# Motivation
	Extend engine2.Entity with macro builder.

	Currently this is autobuild when a class extends engine2.Entity

	1. component
	any field component will be converted to default,set and handle onComponentChanged.
**/
class Entity {
	function new() {}

	function buildEntity() {
		final fields = Context.getBuildFields();

		final localType = Context.getLocalType();
		final localClass = localType.getClass();

		final engine2Component = Context.getType("zf.engine2.Component").getClass();

		/**
			Build component change
		**/
		final newFields = [];
		final toRemove = [];
		for (field in fields) {
			switch (field.kind) {
				case FVar(t, expr):
					final type = t.toType();
					switch (type) {
						case TInst(_.get() => type, params):
							if (Util.isChildOf(type, engine2Component) == false) continue;
							toRemove.push(field);
							newFields.push({
								name: field.name,
								pos: Context.currentPos(),
								kind: FProp("default", "set", t, null),
								access: field.access,
							});

							final fieldName = field.name;

							newFields.push({
								name: 'set_${field.name}',
								pos: Context.currentPos(),
								kind: FFun({
									args: [{name: "component", type: t}],
									expr: macro {
										final prev = this.$fieldName;
										this.$fieldName = component;
										onComponentChanged(prev, this.$fieldName);
										return this.$fieldName;
									}
								}),
								access: field.access,
							});

						default:
					}
				default:
			}
		}

		for (f in toRemove) fields.remove(f);
		for (f in newFields) fields.push(f);

		return fields;
	}

	public static function build() {
		return new Entity().buildEntity();
	}
}
#end
