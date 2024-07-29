package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;

using haxe.macro.Tools;
using haxe.macro.TypeTools;

/**
	# Motivation
	I want to continue to reduce the amount of code I write.

	This means more generalisation and also adding more ways to build classes without having
	to write the boilerplate. This moves the engine into a declarative approach for most boilerplate.

	This is a generic class builder that allows me to build classes

	This class currently support the following builder

	- forward

	# Usage
	Call the macro
	#if !macro @:build(zf.macros.ClassBuilder.build()) #end

	## Delegate

	@forward(["x"]) public var field;

	will generate a inline getter, i.e

	public var x(get, never): <Type>;

	inline public function get_x(): <Type> {
		return this.field?.x;
	}
**/
class ClassBuilder {
	public function new() {}

	function _build() {
		final fields: Array<haxe.macro.Field> = Context.getBuildFields();

		inline function buildDelegate(field: haxe.macro.Field, meta: haxe.macro.Expr.MetadataEntry) {
			switch (field.kind) {
				case FVar(_.toType() => t, e), FProp(_, _, _.toType() => t, e):
					for (f in cast(meta.params[0].getValue(), Array<Dynamic>)) {
						final ft = Util.getTypeOfField(t, '${f}');
						if (ft == null) {
							Context.fatalError('unable to forward ${field.name}.${f}', field.pos);
						}
						final fieldType = Context.toComplexType(ft);
						final fieldName = field.name;
						final innerFieldName = '${f}';
						fields.push(({
							name: '${f}',
							pos: Context.currentPos(),
							kind: FProp("get", "never", fieldType, null),
							access: [APublic],
						}: haxe.macro.Field));

						// TODO: add doc from the child field ?

						fields.push(({
							name: 'get_${f}',
							pos: Context.currentPos(),
							kind: FFun({
								args: [],
								expr: macro {
									return this.$fieldName?.$innerFieldName;
								},
								ret: fieldType,
							}),
							access: [APublic, AInline],
						}: haxe.macro.Field));
					}
				default:
			}
		}

		final toBuild: Array<{field: haxe.macro.Field, meta: MetadataEntry}> = [];

		for (field in fields) {
			final m = Util.getMeta(field.meta, "forward");
			if (m == null) continue;
			toBuild.push({field: field, meta: m});
		}

		for (f in toBuild) {
			buildDelegate(f.field, f.meta);
		}

		return fields;
	}

	public static function build() {
		return new ClassBuilder()._build();
	}
}
#end
