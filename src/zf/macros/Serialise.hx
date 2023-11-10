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
	I know json2object exists.
	However, I already have existing ways of doing things and I didn't want to change them to fit json2object.
	So, I made one myself. This allows me to extend and add new features that are customised to my workflow.

	# Usage
	Automatic serialisation to json.
	This works with SerialiseContext to automatically generate code to convert a Serialisable to a struct.

	Decorate any Serialisable with the macro
	#if !macro @:build(zf.macros.Serialise.build()) #end

	We will not autobuild this via Serialisable because it makes it very weird since we have
	multiple levels of inheritance.

	Available metadata
	- @serialise (key: [null], fromContext: [false])
		key - the store key. if null will use the field name
		fromContext - if true will get the object from context instead of serialising it.
	- @fromContext (key: string)
		this object is never saved, and it is always taken from context via key when loading.
		this key is never saved.

	then we can output a struct via toStruct or __toStruct__(context) if toStruct is defined
	and load the struct via loadStruct or __loadStruct__(context, data) if loadStruct is defined

	# Limitation
	1. When a class is mark with this macro, all fields that are marked with @serialise needs to be either
			A.	A primitive (Int/Float/Bool/String),
			B. 	A Serialisable with a empty() function
			C. 	A Identifiable
			D. 	Is array and the containing type is A/B/C
			E. 	Serialisable takes priority over identifier.
					If the object is both Serialisable and Identifiable, it will be serialised to struct.
					If the intention is to take from context, set fromContext to true
	2. Currently only serialise Serialisable/Primitive/Identifiable.

	Since I don't think need to be super generic and more specific to how I do things, I don't need to over-engineer it.
**/
/**
	Stores the field we want to serialise.

	This information is not stored in the class and is only used during code generation.
**/
private typedef StoredField = {
	public var storeAs: String;
	public var field: haxe.macro.Field;
	public var classType: haxe.macro.Type.ClassType;

	public var isSerialisable: Bool;
	public var isIdentifiable: Bool;
	public var isPrimitive: Bool;
	public var isIterable: Bool;
	public var iterableType: String;
}

/**
	@:unstable
**/
class Serialise {
	var fields: Array<haxe.macro.Field>;

	var fieldsMap: Map<String, haxe.macro.Field>;

	var storeFields: Map<String, StoredField>;

	var toStructExprs: Array<Expr>;
	var loadStructExprs: Array<Expr>;

	public function buildClass() {
		setup();
		constructToStructMethod();
		constructLoadStructMethod();
		return this.fields;
	}

	function setup() {
		this.fields = Context.getBuildFields();
		this.storeFields = [];
		this.fieldsMap = [];
		this.toStructExprs = [];
		this.loadStructExprs = [];

		final localType = Context.getLocalType();
		final localClass = localType.getClass();
		if (Util.hasInterface(localClass, "Serialisable") == false) {
			Context.fatalError('${localClass.name} is not Serialisable', localClass.pos);
		}

		for (f in this.fields) {
			this.fieldsMap.set(f.name, f);
			var hasSerialise = false;
			var hasFromContext = false;
			for (m in f.meta) {
				if (m.name == "serialise") {
					handleSerialise(f, m);
					hasSerialise = true;
				} else if (m.name == "fromContext") {
					handleFromContext(f, m);
					hasFromContext = true;
				}
				if (hasSerialise == true && hasFromContext == true) {
					Context.fatalError('${f.name} cannot be @serialise and @fromConext at the same time.', f.pos);
				}
			}
		}
	}

	function constructLoadStructMethod() {
		final localType = Context.getLocalType();
		final localClass = localType.getClass();
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		var expr: Expr = macro {
			{
				$a{this.loadStructExprs}
			};
			return this;
		}
		var target = "loadStruct";
		var access = [APublic];
		if (this.fieldsMap.exists("loadStruct") == true) {
			target = "__loadStruct__";
		} else if (superClass != null && TypeTools.findField(superClass, "loadStruct") != null) {
			expr = macro {
				super.loadStruct(context, struct);
				{
					$a{this.loadStructExprs}
				};
				return this;
			}
			access.push(AOverride);
		} else {}

		this.fields.push({
			name: target,
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name: "context", type: macro : zf.serialise.SerialiseContext},
					{name: "struct", type: macro : Dynamic},
				],
				expr: expr,
				ret: localType.toComplexType(),
			}),
			access: access,
			doc: null,
			meta: [],
		});
	}

	function constructToStructMethod() {
		final localClass = Context.getLocalType().getClass();
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		var expr: Expr = macro {
			final struct: Dynamic = {};
			{
				$a{toStructExprs}
			};
			return struct;
		};
		var target = "toStruct";
		var access = [APublic];
		final args = [{name: "context", type: macro : zf.serialise.SerialiseContext},];
		if (this.fieldsMap.exists("toStruct") == true) {
			args.push({name: "data", type: macro : Dynamic});
			target = "__toStruct__";
		} else if (superClass != null && TypeTools.findField(superClass, "toStruct") != null) {
			access.push(AOverride);
			expr = macro {
				final struct: Dynamic = super.toStruct(context);
				{
					$a{toStructExprs}
				};
				return struct;
			};
		} else {}

		this.fields.push({
			name: target,
			pos: Context.currentPos(),
			kind: FFun({
				args: args,
				expr: expr,
				ret: macro : Dynamic,
			}),
			access: access,
			doc: null,
			meta: [],
		});
	}

	function handleSerialise(f: haxe.macro.Field, m: haxe.macro.MetadataEntry) {
		final storeAs: String = (m.params.length < 1 || m.params[0].getValue() == null) ? f.name : m.params[0].getValue();
		final fromContext: Bool = (m.params.length < 2) ? false : m.params[1].getValue();
		final localType = Context.getLocalType();
		final localClass = localType.getClass();
		final fieldName = f.name;

		// Handle Primitive
		inline function handlePrimitive() {
			this.toStructExprs.push(macro struct.$storeAs = this.$fieldName);
			this.loadStructExprs.push(macro this.$fieldName = struct.$storeAs);
		}

		// Handle Identifiable
		inline function handleIdentifiable() {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					struct.$storeAs = this.$fieldName.identifier();
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = cast context.get(struct.$storeAs);
				}
			});
		}

		// Handle Serialisable
		inline function handleSerialisable(classType: ClassType) {
			if (Util.getType(classType.name) == null) {
				Context.fatalError('${f.name} Type "${classType.name}" cannot be found', f.pos);
			}
			this.toStructExprs.push(macro {
				struct.$storeAs = this.$fieldName == null ? null : this.$fieldName.toStruct(context);
			});
			if (TypeTools.findField(classType, "empty") != null) {
				this.loadStructExprs.push(macro {
					if (struct.$storeAs != null) {
						if (this.$fieldName == null) {
							this.$fieldName = $i{classType.name}.empty();
						}
						this.$fieldName.loadStruct(context, struct.$storeAs);
					}
				});
			} else {
				this.loadStructExprs.push(macro {
					if (struct.$storeAs != null && this.$fieldName != null) {
						this.$fieldName.loadStruct(context, struct.$storeAs);
					}
				});
			}
		}

		// Handle Array of Primitive
		inline function handleArrayPrimitive() {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					struct.$storeAs = [for (i in this.$fieldName) i];
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = struct.$storeAs;
				}
			});
		}

		// Handle Array of Identifiable
		inline function handleArrayIdentifiable() {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					struct.$storeAs = [for (i in this.$fieldName) i.identifier()];
					for (i in this.$fieldName) context.add(i);
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = [];
					for (id in (struct.$storeAs: Array<String>)) {
						this.$fieldName.push(cast context.get(id));
					}
				}
			});
		}

		// Handle Array of Serialisable
		inline function handleArraySerialisable(classType: ClassType) {
			if (TypeTools.findField(classType, "empty") == null) {
				Context.fatalError('${classType.name} does not have a static empty method.', f.pos);
			}

			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					struct.$storeAs = [];
					for (i in this.$fieldName) {
						struct.$storeAs.push(i.toStruct(context));
					}
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = [];
					for (s in (struct.$storeAs: Array<Dynamic>)) {
						final object = $i{classType.name}.empty();
						object.loadStruct(context, s);
						this.$fieldName.push(object);
					}
				}
			});
		}

		switch (f.kind) {
			case FVar(_.toType() => type, e):
				if (Util.isPrimitive(type) == true) {
					handlePrimitive();
				} else {
					switch (type) {
						case TInst(_.get() => t, p):
							switch (t.name) {
								case "Array":
									if (p.length == 0) {
										Context.fatalError('${f.name} Array cannot be serialised.', f.pos);
									}
									if (Util.isPrimitive(p[0]) == true) {
										// if primitive, takes priority
										handleArrayPrimitive();
									} else if (fromContext == true) {
										// if from context is true, force identifiable
										if ((Util.hasInterface(p[0].getClass(), "Identifiable")) == false) {
											Context.fatalError('${f.name} is not Identifiable', f.pos);
										}
										handleArrayIdentifiable();
									} else if (Util.hasInterface(p[0].getClass(), "Serialisable") == true) {
										// handle array of serialisable
										handleArraySerialisable(p[0].getClass());
									} else if (Util.hasInterface(p[0].getClass(), "Identifiable") == true) {
										// handle array of identifiable
										handleArrayIdentifiable();
									} else {
										// can't handle it yet
										Context.fatalError('${f.name} Array cannot be serialised.', f.pos);
									}
								default:
									if (fromContext == true) {
										// force identifiable
										if ((Util.hasInterface(t, "Identifiable")) == false) {
											Context.fatalError('${f.name} is not Identifiable', f.pos);
										}
										handleIdentifiable();
									} else if (Util.hasInterface(t, "Serialisable") == true) {
										// handle serialisable
										handleSerialisable(t);
									} else if (Util.hasInterface(t, "Identifiable") == true) {
										// handle identifiable
										handleIdentifiable();
									} else {
										Context.fatalError('${f.name} is not Serialisable or Identifable.', f.pos);
									}
							}
						case TDynamic(_):
							Context.fatalError('${f.name} - Dynamic cannot be serialised at the moment.', f.pos);
						default:
					}
				}
			default:
				Context.fatalError('${f.name} is a function and cannot be serialise.', f.pos);
		}
	}

	function handleFromContext(f: haxe.macro.Field, m: haxe.macro.MetadataEntry) {
		if (m.params.length < 1) Context.fatalError('@fromContext requires a key.', f.pos);
		final key: String = m.params[0].getValue();
		final fieldName = f.name;

		// for @fromContext, we will only add the method for loading from context
		this.loadStructExprs.push(macro {
			this.$fieldName = cast context.get($v{key});
		});
	}

	function new() {}

	public static function build() {
		return new Serialise().buildClass();
	}
}
#end

/**
	Thu 14:53:01 11 Jul 2024
	Third time is the charm. Third attempt to do macro to serialise object into struct.

	The first 2 attempts fails because of the lack of understanding with the haxe macro engine and it was beyond me.
	First roadblock was not knowing how to get fields data, which is solved when I was working with ObjectPool
	Second roadblock was not knowing how to properly set up long function in macro, which is solved after
	handling Messages and upgrading of Object Pool

	Thu 15:34:28 11 Jul 2024
	Building a simplified version of struct here instead of the complex one in json2object.
	I just need to handle 2 cases instead of all
	1. the field is a Serialisable
	2. the field is not a Serialisable.

	For 1, we will call toStruct to serialise and loadStruct to unserialise
	For 2, we will set the value directly.

	If this doesn't work, then we upgrade this in the future

	Thu 15:36:00 11 Jul 2024
	Okay, I suddenly remember why I drop this idea previously.
	How do I handle data version upgrade ?
	I guess we have to figure that out later.

	Thu 16:45:27 11 Jul 2024
	Okay first pass seems okay.
	Still unstable to make it autobuild, and I am afraid that this will break Crop Rotation.
	I might upgrade this to autobuild when I do 1.4 for CR.

	Fri 14:30:38 12 Jul 2024
	Add in viaContext to store identifiable in the context

	Sun 13:04:15 14 Jul 2024
	I think adding autobuild is not necessary because we might have cases that we don't want it to be auto.
**/
