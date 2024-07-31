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

	## Field forwarding

	@forward public var field;
	@forward(["x"]) public var field;

	will generate a inline getter, i.e

	public var x(get, never): <Type>;

	inline public function get_x(): <Type> {
		return this.field?.x;
	}

	In the first case, all field will be forwarded, unless the field already exists
	In the second case, only the field that is specified is forward.

	If 2 field forward the same getter/setting, then it will error
**/
class ClassBuilder {
	public function new() {}

	function _build() {
		final fields: Array<haxe.macro.Field> = Context.getBuildFields();

		final fieldsMap: Map<String, haxe.macro.Field> = [];

		for (f in fields) {
			fieldsMap.set(f.name, f);
		}

		final created: Map<String, Bool> = [];

		inline function buildField(field: haxe.macro.Field, fieldType: haxe.macro.Type, innerFieldName: String) {
			final fieldType = Context.toComplexType(fieldType);
			final fieldName = field.name;
			fields.push(({
				name: innerFieldName,
				pos: Context.currentPos(),
				kind: FProp("get", "never", fieldType, null),
				access: [APublic],
			}: haxe.macro.Field));

			// TODO: add doc from the child field ?

			fields.push(({
				name: 'get_${innerFieldName}',
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
			created.set(innerFieldName, true);
		}

		function buildDelegate(field: haxe.macro.Field, meta: haxe.macro.Expr.MetadataEntry) {
			switch (field.kind) {
				case FVar(_.toType() => t, e), FProp(_, _, _.toType() => t, e):
					if (meta.params.length == 0) {
						// if no field is specified, we try to forward everything
						for (f in Util.getAllFields(t)) {
							if (fieldsMap.exists(f.name) == true) continue;
							if (created.exists(f.name) == true)
								Context.fatalError('Duplicated forwarding for ${f.name}.', field.pos);

							buildField(field, f.type, '${f.name}');
						}
					} else {
						for (f in cast(meta.params[0].getValue(), Array<Dynamic>)) {
							final ft = Util.getTypeOfField(t, '${f}');
							if (ft == null) {
								Context.fatalError('unable to forward ${field.name}.${f}', field.pos);
							}
							buildField(field, ft, '${f}');
						}
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
