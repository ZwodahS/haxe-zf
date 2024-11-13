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
	Extend engine2.Component with macro builder.

	Currently this is autobuild when a class extends engine2.Component

	## Component.get(Entity)
	There are 2 ways to get component from an entity.

	1. In child entity, store the reference to the component
	i.e. any child with a var component automatically get build with a setting that uses onComponentChanged
	2. entity.getComponent

	However, that requires getComponent(Component.TypeId) + a cast
	This is kind of tedious to write.
	This macro will generate Component.get(Entity) method that is static

	i.e

	var entity = ....
	var component = XXXComponent.get(entity);

	This will get XXXComponent from the entity if it exists

	Similarly, it will also generate XXXComponent.exists(entity) which returns a bool that
	denote if the entity has the component

	## get_typeId()
	Previously all child class will have to override this manually.
	With this macro, it will be automatically generated if it doesn't exists,
	and if ComponentType static field is provided.
**/
class Component {
	function new() {}

	function buildComponent() {
		final fields = Context.getBuildFields();

		final localType = Context.getLocalType();
		final localClass = localType.getClass();

		var componentType = null;

		final engine2Entity = Context.getType("zf.engine2.Entity").toComplexType();

		for (field in fields) {
			if (field.name == "ComponentType") {
				componentType = field;
			}
		}

		// if component type not specified, then we don't build it
		if (componentType == null) return fields;

		fields.push({
			name: 'get',
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name: "entity", type: engine2Entity}],
				expr: macro {
					return cast entity?.getComponent(ComponentType);
				},
				ret: localType.toComplexType(),
			}),
			access: [AStatic, APublic, AInline],
		});

		fields.push({
			name: 'exists',
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name: "entity", type: engine2Entity}],
				expr: macro {
					return entity?.getComponent(ComponentType) != null;
				},
				ret: macro : Bool
			}),
			access: [AStatic, APublic, AInline],
		});

		fields.push({
			name: "get_typeId",
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro {
					return ComponentType;
				},
				ret: macro : String,
			}),
			access: [APublic, AOverride],
		});

		return fields;
	}

	public static function build() {
		return new Component().buildComponent();
	}
}
#end
