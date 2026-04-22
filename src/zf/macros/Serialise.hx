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
	- @:serialise (key: [null], fromContext: [false], loadPriority: [0])
		key - the store key. if null will use the field name
		fromContext - if true will get the object from context instead of serialising it.
		loadPriority - default 0, lower number will be loaded first.
	- @:init (function: String)
		function - the static function to call to init the object.
		default to `alloc()` if not provided.
	- @:fromContext (key: string)
		this object is never saved, and it is always taken from context via key when loading.
		this key is never saved.

	@:serialise(null, true) vs @:fromContext("key")
	In the case of @:fromContext, it is never serialise and the key is always taken from context.
	@:serialise(null, true) will serialise the object into a key via .identifier().

	# Limitation
	1. When a class is mark with this macro, all fields that are marked with @:serialise needs to be either
			A.	A primitive (Int/Float/Bool/String),
			B. 	A Serialisable
			C. 	A Identifiable
			D. 	Is array and the containing type is A/B/C
			E. 	Serialisable takes priority over identifier.
					If the object is both Serialisable and Identifiable, it will be serialised to struct.
					If the intention is to take from context, set fromContext to true
	2. Currently only serialise Serialisable/Primitive/Identifiable.

	Since I don't think need to be super generic and more specific to how I do things, I don't need to over-engineer it.

	# Additional Notes
	When loadStruct is defined in parent, super.loadStruct will automatically be called.
	When loadStruct is defined in the class, a new loadStruct will be created with the existing loadStruct's Expr
	added after the generated code.
	To add code before the loadStruct, create a function preLoadStruct.
	This method must have the same method signature.
	Also note that there should not be a return statement in preLoadStruct

	Similarly when toStruct is defined in parent, struct = super.toStruct will be added automatically.
	When toStruct is defiend in the current class, the code for it will be added after the generated code.
	It can be safely assumed that struct is defined then.
	Unlike loadStruct, there is no preToStruct as there are no need for it.
	toStruct need to return struct if it is defined in the current class

	Note that in both loadStruct and toStruct, `context` and `struct` are used as the arguments.
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

		var toSerialise = [];

		for (f in this.fields) {
			this.fieldsMap.set(f.name, f);
			var hasSerialise = false;
			var hasFromContext = false;
			for (m in f.meta) {
				if (m.name == ":serialise") {
					// handle serialise separately, since I need to handle load priority
					final priority: Int = (m.params.length < 3) ? 0 : m.params[2].getValue();
					toSerialise.push({f: f, m: m, p: priority});
					hasSerialise = true;
				} else if (m.name == ":fromContext") {
					handleFromContext(f, m);
					hasFromContext = true;
				}
				if (hasSerialise == true && hasFromContext == true) {
					Context.fatalError('${f.name} cannot be @:serialise and @fromConext at the same time.', f.pos);
				}
			}
		}

		toSerialise.sort((d1, d2) -> zf.Compare.int(1, d1.p, d2.p));

		for (d in toSerialise) handleSerialise(d.f, d.m);
	}

	function constructLoadStructMethod() {
		final localType = Context.getLocalType();
		final localClass = localType.getClass();
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		final superHasMethod = superClass == null ? false : TypeTools.findField(superClass, "loadStruct") != null;
		final current = this.fieldsMap.get("loadStruct");
		final preLoad = this.fieldsMap.get("preLoadStruct");

		final superMethodExpr: Array<Expr> = [];
		final preMethodExpr: Array<Expr> = [];
		final postMethodExpr: Array<Expr> = [];
		final returnExpr: Array<Expr> = [];

		var access = [APublic];
		if (superHasMethod == true) { // handle the case of parent class having the method
			superMethodExpr.push(macro {
				super.loadStruct(context, struct);
			});
			access.push(AOverride);
		}

		if (preLoad != null) { // handle preLoadStruct
			this.fields.remove(preLoad);
			this.fieldsMap.remove("preLoadStruct");
			final e = switch (preLoad.kind) {
				case FFun(func):
					func.expr;
				default:
					Context.fatalError("preLoadStruct is not a function", preLoad.pos);
			}
			preMethodExpr.push(e);
		}

		if (current != null) { // handle current
			this.fields.remove(current);
			this.fieldsMap.remove("loadStruct");
			final e = switch (current.kind) {
				case FFun(func):
					func.expr;
				default:
					Context.fatalError("loadStruct is not a function", current.pos);
			}
			postMethodExpr.push(e);
		} else { // if there is no current, then we need to create the return statement
			returnExpr.push(macro {return this;});
		}

		this.fields.push(cast {
			name: "loadStruct",
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name: "context", type: macro : zf.serialise.SerialiseContext},
					{name: "struct", type: macro : Dynamic},
				],
				expr: macro {
					$b{superMethodExpr};
					$b{preMethodExpr};
					$b{this.loadStructExprs};
					$b{postMethodExpr};
					$b{returnExpr};
				},
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

		final superHasMethod = superClass == null ? false : TypeTools.findField(superClass, "toStruct") != null;
		final current = this.fieldsMap.get("toStruct");

		final structConstructionExpr: Array<Expr> = [];
		final postMethodExpr: Array<Expr> = [];
		final returnExpr: Array<Expr> = [];

		final args = [
			{name: "context", type: macro : zf.serialise.SerialiseContext},
			{name: "struct", type: macro : Dynamic, value: macro null},
		];
		final access = [APublic];

		if (superHasMethod == true) {
			access.push(AOverride);
			structConstructionExpr.push(macro {
				struct = super.toStruct(context, struct);
			});
		} else {
			structConstructionExpr.push(macro {
				if (struct == null) struct = {};
			});
		}

		if (current != null) {
			this.fields.remove(current);
			this.fieldsMap.remove("toStruct");
			final e = switch (current.kind) {
				case FFun(func):
					func.expr;
				default:
					Context.fatalError("toStruct is not a function", current.pos);
			}
			postMethodExpr.push(e);
		} else {
			returnExpr.push(macro {return struct;});
		}

		this.fields.push({
			name: "toStruct",
			pos: Context.currentPos(),
			kind: FFun({
				args: args,
				expr: macro {
					$b{structConstructionExpr};
					$b{this.toStructExprs};
					$b{postMethodExpr};
					$b{returnExpr};
				},
				ret: macro : Dynamic,
			}),
			access: access,
			doc: null,
			meta: [],
		});

		var expr: Expr = macro {
			final struct: Dynamic = {};
			{
				$a{toStructExprs}
			};
			return struct;
		};
	}

	function handleSerialise(f: haxe.macro.Field, m: haxe.macro.MetadataEntry) {
		final storeAs: String = (m.params.length < 1 || m.params[0].getValue() == null) ? f.name : m.params[0].getValue();
		final fromContext: Null<Bool> = (m.params.length < 2) ? null : m.params[1].getValue();
		final localType = Context.getLocalType();
		final localClass = localType.getClass();
		final fieldName = f.name;
		final init = f.meta.findOne((m) -> {
			m.name == ":init";
		});
		final initFuncName = (init == null || init.params.length == 0) ? "alloc" : init.params[0].getValue();

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

		// Handle Serialisable?
		inline function handleSerialisable(classType: ClassType) {
			if (Util.getType(classType.name) == null) {
				Context.fatalError('${f.name} Type "${classType.name}" cannot be found', f.pos);
			}
			this.toStructExprs.push(macro {
				struct.$storeAs = this.$fieldName == null ? null : this.$fieldName.toStruct(context);
			});
			if (init == null) {
				Context.info("Serialisable without :init, intended ?", f.pos);
				this.loadStructExprs.push(macro {
					if (struct.$storeAs != null && this.$fieldName != null) {
						this.$fieldName.loadStruct(context, struct.$storeAs);
					}
				});
			} else {
				if (initFuncName == null) {
					this.loadStructExprs.push(macro {
						if (struct.$storeAs != null) {
							if (this.$fieldName != null) {
								this.$fieldName.loadStruct(context, struct.$storeAs);
							} else {
								haxe.Log.trace("[Warn] " + $v{fieldName} + " is not initialised");
							}
						}
					});
				} else if (initFuncName == "new") {
					final typePath: haxe.macro.TypePath = {
						pack: classType.pack,
						name: classType.name
					}
					this.loadStructExprs.push(macro {
						if (struct.$storeAs != null) {
							if (this.$fieldName == null) this.$fieldName = new $typePath();
							this.$fieldName.loadStruct(context, struct.$storeAs);
						}
					});
				} else {
					this.loadStructExprs.push(macro {
						if (struct.$storeAs != null) {
							if (this.$fieldName == null) this.$fieldName = $i{classType.name}.$initFuncName();
							this.$fieldName.loadStruct(context, struct.$storeAs);
						}
					});
				}
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
					struct.$storeAs = [for (i in this.$fieldName) i?.identifier()];
					for (i in this.$fieldName) context.add(i);
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = [];
					for (id in (struct.$storeAs: Array<String>)) {
						if (id == null) {
							this.$fieldName.push(null);
						} else {
							this.$fieldName.push(cast context.get(id));
						}
					}
				}
			});
		}

		// Handle Array of Serialisable
		inline function handleArraySerialisable(classType: ClassType) {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					struct.$storeAs = [];
					for (i in this.$fieldName) {
						struct.$storeAs.push(i.toStruct(context));
					}
				}
			});
			if (init == null || initFuncName == null) {
				if (init == null) Context.info("Array of Serialisable without :init, intended ?", f.pos);
				this.loadStructExprs.push(macro {
					if (struct.$storeAs != null) {
						for (ind => s in (struct.$storeAs: Array<Dynamic>)) {
							final object = this.$fieldName[ind];
							object.loadStruct(context, s);
						}
					}
				});
			} else {
				this.loadStructExprs.push(macro {
					if (struct.$storeAs != null) {
						this.$fieldName = [];
						for (s in (struct.$storeAs: Array<Dynamic>)) {
							final object = $i{classType.name}.$initFuncName();
							object.loadStruct(context, s);
							this.$fieldName.push(object);
						}
					}
				});
			}
		}

		inline function handleMapPrimitive() {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					final s: haxe.DynamicAccess<Dynamic> = {};
					struct.$storeAs = s;
					for (key => value in this.$fieldName) {
						s.set(key, value);
					}
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = [];
					for (key => value in (struct.$storeAs: haxe.DynamicAccess<Dynamic>)) {
						this.$fieldName.set(cast key, cast value);
					}
				}
			});
		}

		inline function handleMapSerialisable(classType: ClassType) {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					final s: haxe.DynamicAccess<Dynamic> = {};
					struct.$storeAs = s;
					for (key => value in this.$fieldName) {
						s.set(key, value.toStruct(context));
					}
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = [];
					for (key => value in (struct.$storeAs: haxe.DynamicAccess<Dynamic>)) {
						final object = $i{classType.name}.$initFuncName();
						object.loadStruct(context, value);
						this.$fieldName.set(cast key, object);
					}
				}
			});
		}

		inline function handleMapIdentifiable() {
			this.toStructExprs.push(macro {
				if (this.$fieldName != null) {
					final s: haxe.DynamicAccess<Dynamic> = {};
					struct.$storeAs = s;
					for (key => value in this.$fieldName) {
						s.set(key, value.identifer());
					}
				}
			});
			this.loadStructExprs.push(macro {
				if (struct.$storeAs != null) {
					this.$fieldName = [];
					for (key => value in (struct.$storeAs: haxe.DynamicAccess<Dynamic>)) {
						this.$fieldName.set(cast key, context.get(value));
					}
				}
			});
		}

		function process(type: haxe.macro.Type, e: haxe.macro.Expr) {
			if (Util.isPrimitive(type) == true) {
				handlePrimitive();
			} else {
				switch (type) {
					case TInst(_.get() => t, p):
						switch (t.name) {
							case "Array":
								if (p.length == 0) {
									Context.fatalError('${f.name} Array cannot be serialised - type required.', f.pos);
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
									// if serialisable + identifiable, warn if fromContext is not set
									if (fromContext == null
										&& Util.hasInterface(p[0].getClass(), "Identifable") == true) {
										Context.info("[Warn] Serialisable + Identifiable. Intended (fromContext: false) ?",
											f.pos);
									}
									// handle array of serialisable
									handleArraySerialisable(p[0].getClass());
								} else if (Util.hasInterface(p[0].getClass(), "Identifiable") == true) {
									// handle array of identifiable that is not serialisable
									handleArrayIdentifiable();
								} else {
									Context.fatalError('${f.name} Array cannot be serialised - unable to handle type.',
										f.pos);
								}
							default:
								if (fromContext == true) {
									// force identifiable
									if ((Util.hasInterface(t, "Identifiable")) == false) {
										Context.fatalError('${f.name} is not Identifiable', f.pos);
									}
									handleIdentifiable();
								} else if (Util.hasInterface(t, "Serialisable") == true) {
									if (fromContext == null && (Util.hasInterface(t, "Identifiable") == true)) {
										Context.info("[Warn] Serialisable + Identifiable. Intended (fromContext: false) ?",
											f.pos);
									}
									// handle serialisable
									handleSerialisable(t);
								} else if (Util.hasInterface(t, "Identifiable") == true) {
									// handle identifiable that is not serialisable
									handleIdentifiable();
								} else {
									Context.fatalError('${f.name} is not Primitive, Serialisable or Identifable.',
										f.pos);
								}
						}
					case TType(_.get() => t, p):
						switch (t.type) {
							case TAnonymous(_.get() => it):
								// ensure that all fields are primitive or array of primitive
								for (field in it.fields) {
									if (Util.isPrimitive(field.type) == false
										&& Util.isArrayOfPrimitive(field.type) == false) {
										// @formatter:off
										Context.fatalError(
											'${f.name} - cannot be serialise. Struct requires all type to be primitive or array of primitives.',
											f.pos
										);
									}
								}
								// for structs like these, we will just handle it like primitive
								/**
									Wed 15:16:27 18 Sep 2024
									Not sure if this is the best way to do it but it should work.
									In the future, might consider the option of individually handle serialisable and identifiable.
									However, at that point, we might not want to use struct and just create a class instead.
								**/
								handlePrimitive();
							case TAbstract(_.get() => it, _):
								// for Abstract type, we will just handle Map for now.
								switch (t.name) {
									case "Map":
										if (p.length != 2) {
											Context.fatalError('${f.name} Map - cannot be serialise.', f.pos);
										}
										if (Util.isString(p[0]) == false) {
											// handle only string type key for now.
											Context.fatalError('[NotImplemented] ${f.name} Map - cannot be serialise. Key must be String',
												f.pos);
										}
										if (Util.isPrimitive(p[1]) == true) {
											handleMapPrimitive();
										} else if (fromContext == true) {
											Context.fatalError('[NotImplemented] ${f.name} @:fromContext cannot be used on Map.',
												f.pos);
										} else if (Util.hasInterface(p[1].getClass(), "Serialisable") == true) {
											// handle array of serialisable
											handleMapSerialisable(p[1].getClass());
										} else if (Util.hasInterface(p[1].getClass(), "Identifiable") == true) {
											handleMapIdentifiable();
										} else {
											// can't handle it yet
											Context.fatalError('${f.name} Map cannot be serialised.', f.pos);
										}
									default:
										Context.fatalError('[NotImplemented] ${f.name} of type ${t.name} - cannot be serialise.',
											f.pos);
								}
							default:
						}
					case TDynamic(_):
						Context.fatalError('${f.name} - Dynamic cannot be serialised at the moment.', f.pos);
					case TEnum(_, _):
						// Might have to handle this eventually since there are times that certain field are handled
						// via enum with composite params. Perhaps in those cases we should then use Object ?
						Context.fatalError('${f.name} - Enum cannot be serialised. Use enum abstract.', f.pos);
					case TAnonymous(_.get() => it):
						// ensure that all fields are primitive or array of primitive
						for (field in it.fields) {
							if (Util.isPrimitive(field.type) == false
								&& Util.isArrayOfPrimitive(field.type) == false) {
								// @formatter:off
								Context.fatalError(
									'${f.name} - cannot be serialise. Struct requires all type to be primitive or array of primitives.',
									f.pos
								);
							}
						}
						handlePrimitive();
					case TAbstract(_.get() => it, _):
						// process as the underlying type
						process(it.type, e);
					default:
						Context.fatalError('${f.name} of type ${type} - cannot be serialise.', f.pos);
				}
			}
		}

		switch (f.kind) {
			case FVar(_.toType() => type, e):
				process(type, e);
			case FProp(_, _, _.toType() => type, e):
				process(type, e);
			default:
				Context.fatalError('${f.name} is a function and cannot be serialise.', f.pos);
		}
	}

	function handleFromContext(f: haxe.macro.Field, m: haxe.macro.MetadataEntry) {
		if (m.params.length < 1) Context.fatalError('@:fromContext requires a key.', f.pos);
		final key: String = m.params[0].getValue();
		final fieldName = f.name;

		// for @:fromContext, we will only add the method for loading from context
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

	Wed 14:33:22 21 Aug 2024
	Rename @serialise -> @:serialise, @fromContext -> @:fromContext

	Wed 20:05:35 04 Sep 2024
	I can't use TypeTools to findField to ensure the existence of empty.

	Mon 13:41:43 07 Jul 2025
	Since I can't use TypeTools.findField to find empty, not sure why.
	I going to not assume then.
	I will be adding @:init. This will be used together with @:serialise to handle how objects are created.
	@:init(function: String) - default to alloc(), previously I wanted to use empty but now that this is
	explicit there is no need to do so.

	Wed 13:16:08 09 Jul 2025
	Redo loadStruct to inline instead of using __loadStruct__.
	This is due to the circular logic when __loadStruct__ is both defined in parent and current, which
	causes __loadStruct__ is called multiple times.

	Wed 14:25:56 09 Jul 2025
	Redo toStruct to inline instead of using __toStruct__
	Same reason as loadStruct, need to handle the cases where parent and child both uses the macros.
**/
