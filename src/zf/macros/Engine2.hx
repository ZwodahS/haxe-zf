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
	I need a macro builder for my engine2.

	Currently this is used for the following

	## Collecting Entities
	When using engine2, I need to collect entities, either to serialise or perform operation on them.
	I am hoping with a macro, I can solve this problem

	# Usage

	#if !macro @:build(zf.macros.Engine2.collectEntities()) #end

	This will generate a method "collectEntities" which will automatically add
	all entities to the Entities<Entity>
	If parent class has collectEntities, it will also call it.
	If this class has collectEntities, __collectEntities__ will be generated instead.
	If this class is an Entity, then entities.add(this) will also be called.

	If a field is a EntityContainer, collectEntities will also be called on it.

**/
class Engine2 {
	function new() {}

	function buildCollectEntities() {
		final fields = Context.getBuildFields();
		final localType = Context.getLocalType();
		final localClass = localType.getClass();
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		if (Util.hasInterface(localClass, "EntityContainer") == false) {
			Context.fatalError('${localClass.name} need to be EntityContainer', localClass.pos);
		}

		var target = "collectEntities";
		final engine2Entity = Context.getType("zf.engine2.Entity").getClass();

		final exprs: Array<Expr> = [];
		for (field in fields) {
			final fieldName = field.name;
			if (field.name == "collectEntities") {
				target = "__collectEntities__";
				continue;
			}
			final m = Util.getMeta(field.meta, "collectEntity");
			if (m == null) continue;

			switch (field.kind) {
				case FVar(_.toType() => type, e):
					switch (type) {
						case TInst(_.get() => t, p):
							switch (t.name) {
								case "Array":
									if (p.length == 0) Context.fatalError('${fieldName} Array cannot be collected.',
										field.pos);
									if (Util.hasInterface(p[0].getClass(), "EntityContainer") == true) {
										exprs.push(macro {
											if (this.$fieldName != null) {
												for (obj in this.$fieldName) {
													if (obj != null) obj.collectEntities(entities);
												}
											}
										});
									} else {
										Context.fatalError('${fieldName} must be an Array of EntityContainer or Entity',
											field.pos);
									}
								default:
									if (Util.hasInterface(t, "EntityContainer") == true) {
										exprs.push(macro {
											if (this.$fieldName != null) this.$fieldName.collectEntities(entities);
										});
									} else if (Util.isChildOf(t, engine2Entity)) {
										// This is actually unlikely to be called, because I will probably make all Entity
										// a EntityContainer so all Entity will be Entity anyway.
										exprs.push(macro {
											if (this.$fieldName != null) entities.add(this.$fieldName);
										});
									} else {
										Context.fatalError('${fieldName} must be an EntityContainer or Entity',
											field.pos);
									}
							}
						default:
					}
				default:
					continue;
			}
		}

		var hasParentMethod = false;
		var access = [APublic];
		if (target == "collectEntities") {
			if (superClass != null && TypeTools.findField(superClass, "collectEntities") != null) {
				access.push(AOverride);
				hasParentMethod = true;
			} else {
				access.push(AInline);
			}
		} else {
			access.push(AInline);
		}

		fields.push({
			name: target,
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name: "entities", type: macro : zf.engine2.Entities<zf.engine2.Entity>}],
				expr: macro {
					$a{exprs}
				},
				ret: macro : Void,
			}),
			access: access,
		});

		return fields;
	}

	public static function collectEntities() {
		return new Engine2().buildCollectEntities();
	}
}
#end

/**
	Sun 16:38:56 14 Jul 2024
	Start of macro
**/
