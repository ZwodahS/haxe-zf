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

	@:forward public var field;
	@:forward(["x"]) public var field;

	will generate a inline getter, i.e

	public var x(get, never): <Type>;

	inline public function get_x(): <Type> {
		return this.field?.x;
	}

	In the first case, all field will be forwarded, unless the field already exists
	In the second case, only the field that is specified is forward.

	If 2 field forward the same getter/setting, then it will error

	## Chain
	@:chain public var field: <Type>;

	will generate 1 method to set the field and returning the object

	inline public function _field(v: <Type>): <ClassType> {
		this.field = v;
		return this;
	}
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

		inline function buildDelegateField(field: haxe.macro.Field, fieldType: haxe.macro.Type,
				innerFieldName: String, doc: String) {
			final fieldType = Context.toComplexType(fieldType);
			final fieldName = field.name;
			fields.push(({
				name: innerFieldName,
				pos: Context.currentPos(),
				kind: FProp("get", "never", fieldType, null),
				access: [APublic],
				doc: doc,
			}: haxe.macro.Field));

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
				doc: doc,
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

							buildDelegateField(field, f.type, '${f.name}', f.doc);
						}
					} else {
						for (f in cast(meta.params[0].getValue(), Array<Dynamic>)) {
							final ft = Util.getTypeOfField(t, '${f}');
							if (ft == null) {
								Context.fatalError('unable to forward ${field.name}.${f}', field.pos);
							}
							buildDelegateField(field, ft, '${f}', Util.getDocOfField(t, '${f}'));
						}
					}
				default:
			}
		}

		function buildChain(field: haxe.macro.Field, meta: haxe.macro.Expr.MetadataEntry) {
			switch (field.kind) {
				case FVar(_.toType() => t, e), FProp(_, _, _.toType() => t, e):
					final fieldName = field.name;
					fields.push({
						name: '_${field.name}',
						pos: Context.currentPos(),
						kind: FFun({
							args: [{name: "v", type: t.toComplexType()}],
							expr: macro {
								this.$fieldName = v;
								return this;
							}
						}),
						access: [APublic, AInline],
					});
				default:
					Context.fatalError('unable to build chain for field ${field.name} - Not a field', field.pos);
			}
		}

		final toBuildDelegate: Array<{field: haxe.macro.Field, meta: MetadataEntry}> = [];
		final toBuildChain: Array<{field: haxe.macro.Field, meta: MetadataEntry}> = [];

		for (field in fields) {
			final forwardMeta = Util.getMeta(field.meta, ":forward");
			if (forwardMeta != null) {
				toBuildDelegate.push({field: field, meta: forwardMeta});
			}

			final chainMeta = Util.getMeta(field.meta, ":chain");
			if (chainMeta != null) {
				if (forwardMeta != null) {
					Context.fatalError('@:chain does not work with @:forward: ${field.name}', field.pos);
				}
				toBuildChain.push({field: field, meta: chainMeta});
			}
		}

		for (f in toBuildDelegate) {
			buildDelegate(f.field, f.meta);
		}

		for (f in toBuildChain) {
			buildChain(f.field, f.meta);
		}

		return fields;
	}

	public static function build() {
		return new ClassBuilder()._build();
	}
}
#end

/**
	Wed 14:33:56 21 Aug 2024
	Rename @forward -> @:forward
**/
