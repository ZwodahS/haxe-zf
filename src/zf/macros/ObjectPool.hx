package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;

using haxe.macro.Tools;
using haxe.macro.TypeTools;

/**
	ObjectPool is a macro-based object pool library.

	The following fields should not exists in the class.
	- __pool__ will be created and used to store the pool
	- __next__ will be created and used to make this object a linked list
	- __poolCount__ will be created to store the number of object in pool.
	- __poolCreated__ will be created to store the number of object created

	- dispose
	dispose method will be added to return the object back to the pool.
	if this method is defined by class, the dispose method will be modified and
		additional exprs will be added it it.
	if this method is defined by parent but not current class, a dispose method will also be created
		it will call super.dispose and the additional statements will be added it.

	- reset
	if reset method is present, it will be called when the object is disposed after all the generated statements.
	Note that if parent is built via this macro, and has `reset` and children is built using
	this macro, and also has `reset` method, the `reset` method will be called twice.
	Be careful when defining reset function because of this.

	- alloc or __alloc__
	alloc method to get an instance of the object.
	If alloc exists, __alloc__ will be created instead.
	Call __alloc__ in the custom alloc method to get the object.

	# Usage
	```
	#if !macro @:build(zf.macros.ObjectPool.build()) #end
	class XXX {}
	```

	If you want to only generate the dispose method without generating the object pool (i.e. for parent class)
	you can also use this macro by passing false
	```
	#if !macro @:build(zf.macros.ObjectPool.build(false)) #end
	```
	## Field metadata

	### 1. @:dispose
	@:dispose generates the code used to dispose the field.

	@:dispose(type, ...)

	type - "all" (default) (T0) (TOe)
	This disposes the field "smartly" based on the rules belows
	1. For primitive|enum|function, it will be handled like type-"set" and a default value is needed.
	2. For object with dispose function, call dispose then set it to null
	For Array - See note below

	type - "func" (T1)
	Call a function on the object.
	For example @:dispose("func", "clear") will call the clear function of the object
	This will not set the value of the field

	type - "set" (T2)
	Set the value of field to the default value provided.
	If an additional value is provided in the second params of @:dispose
	then it will be set to the second params of @:dispose

	@:dispose("set") public var x: Int = 0;
	will dispose it to 0.

	@:dispose("set", 0) public var x: Int;
	will also dispose it to 0

	Dealing with array.
	There are a few cases usually with array

	1. Clear the array without updating the field.
	2. Set the field to null
	3. Call "dispose" on all items in array, then empty the array
	4. Call "dispose" on all items in array, then set array to null

	Case 1 is handled via (AO1)
	@:dispose("func", "clear") public var arr: Array<Object>;
	Case 2 is handled via (AO2)
	@:dispose("set") public var arr: Array<Object> = null;
	Case 3 is handled via (AO3)
	@:dispose public var arr: Array<Object>;
	Case 4 is handled via (AO4)
	@:dispose public var arr: Array<Object> = null;

	In both AO3 and AO4, the array will be cleared, since the objects are disposed

	Because Array can also contains primitive or object that cannot be disposed
	case 1 can be handled by @:dispose for primitive case via (AP1)
	@:dispose public var arr: Array<Int>;

	case 2 can be handled by @:dispose for primitive case via (AP2)
	@:dispose public var arr: Array<Int> = null;

	# Additional notes:
	1. constructor of the object need to be empty if we are building object pool
	2. object can still be created using new, and can still be disposed.
	3. ObjectPool object should not be extended. If intended to be extended, it is advisable to build
		only the dispose method.

	# dependencies
	- zf.macros.Util.
	- zf.Disposable
**/
class ObjectPool {
	function new() {}

	function generateResetExprs(): Array<Expr> {
		final fields = Context.getBuildFields();
		final resetExprs: Array<Expr> = [];
		inline function generateSet(f: haxe.macro.Field, e: Expr) {
			if (e == null) Context.fatalError("must be Disposable or default value required.", f.pos);
			final fieldName = f.name;
			resetExprs.push(macro {this.$fieldName = ${e};});
		}

		inline function generateDisposeSetNull(f: haxe.macro.Field, e: Expr) {
			final fieldName = f.name;
			resetExprs.push(macro {
				if (this.$fieldName != null) this.$fieldName.dispose();
				this.$fieldName = null;
			});
		}

		inline function generateArrayClear(f: haxe.macro.Field) {
			final fieldName = f.name;
			resetExprs.push(macro {
				if (this.$fieldName != null) this.$fieldName.resize(0);
			});
		}

		function handleFullDispose(f: haxe.macro.Field, explicit: Bool = false) {
			final fieldName = f.name;
			switch (f.kind) {
				case FVar(_.toType() => type, e), FProp(_, _, _.toType() => type, e):
					if (type == null) Context.fatalError('@:dispose requires explicit type', f.pos);
					if (Util.isArray(type) == true) {
						final arrType = Util.getArrayType(type);
						if (arrType == null) {
							// not sure why this will be null, but in this case we will just generate to a set
							generateSet(f, e);
						} else if (Util.isPrimitive(arrType) == true
							|| Util.isEnum(arrType) == true
							|| Util.hasInterface(arrType.getClass(), "Disposable") == false) {
							if (e == null) { // AP1
								generateArrayClear(f);
							} else { // AP2
								generateSet(f, e);
							}
						} else { // object that should be disposable
							// regardless of what we want to do, if this is not explicit, we warn
							// because disposing all object will cause error in game state
							if (explicit == false) {
								Context.info('[Warn] ${fieldName} is an array of Disposable marked to be dispose. Intended ?',
									f.pos);
							}
							resetExprs.push(macro {
								if (this.$fieldName != null) {
									for (o in this.$fieldName) o.dispose();
									this.$fieldName.resize(0);
								}
							});
							if (e != null) generateSet(f, e);
						}
					} else if (Util.isPrimitive(type) == true
						|| Util.isEnum(type) == true
						|| Util.isFunction(type) == true
						|| Util.isObject(type) == false
						|| Util.hasInterface(Util.getClass(type), "Disposable") == false) {
						generateSet(f, e);
					} else { // dispose function exists
						if (e != null && explicit == false) {
							// with a default value, so we don't dispose
							Context.info('[Warn] ${fieldName} is Disposable with a default value. Intended ?', f.pos);
							generateSet(f, e);
						} else {
							generateDisposeSetNull(f, e);
						}
					}
				default:
					Context.fatalError('${f.name} cannot be disposed.', f.pos);
			}
		}

		function handleFuncDispose(f: haxe.macro.Field, funcName: String) {
			switch (f.kind) {
				case FVar(_.toType() => type, e):
					if (Util.isPrimitive(type) == true) {
						Context.fatalError("unable to call function on primitive.", f.pos);
					}
					final fieldName = f.name;
					resetExprs.push(macro {
						if (this.$fieldName != null) this.$fieldName.$funcName();
					});
				default:
					Context.fatalError('${f.name} cannot be disposed.', f.pos);
			}
		}

		function handleSetDispose(f: haxe.macro.Field, value: Expr) {
			if (value == null) {
				switch (f.kind) {
					case FVar(_.toType() => type, e), FProp(_, _, _.toType() => type, e):
						if (e == null) Context.fatalError('${f.name} requires a default value or a set value.', f.pos);
						if (Util.isArray(type) == false
							&& (Util.isPrimitive(type) == true
								|| Util.isEnum(type) == true
								|| Util.isFunction(type) == true
								|| Util.hasInterface(type.getClass(), "Disposable") == false)) {
							Context.info('[Hint] "set" here is not necessary', f.pos);
						}
						generateSet(f, e);
					default:
						Context.fatalError('${f.name} cannot be disposed.', f.pos);
				}
			} else {
				generateSet(f, value);
			}
		}

		// find all the field that needs to be disposed
		for (f in fields) {
			final meta = Util.getMeta(f.meta, ":dispose");
			if (meta == null) continue;

			if (meta.params.length == 0) { // T0
				handleFullDispose(f);
			} else if (meta.params[0].getValue() == "all") { // T0e
				handleFullDispose(f, true);
			} else if (meta.params[0].getValue() == "func") { // T1
				if (meta.params.length < 2) Context.fatalError('@:dispose("func") requires a function name', f.pos);
				handleFuncDispose(f, meta.params[1].getValue());
			} else if (meta.params[0].getValue() == "set") { // T2
				handleSetDispose(f, meta.params.length < 2 ? null : meta.params[1]);
			} else {
				Context.fatalError('Invalid dispose type ${meta.params[0].getValue()}.', f.pos);
			}
		}

		return resetExprs;
	}

	function setupObjectPool() {
		final fields = Context.getBuildFields();
		final localClass = Context.getLocalClass();
		final className = '${localClass}';
		final type = Context.getLocalType();
		final localClass = type.getClass();
		final typePath = {name: localClass.name, pack: localClass.pack};
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		var resetFunc = null;
		var allocFunc = null;
		var disposeFunc = null;

		/**
			Check for existing function
		**/
		for (f in fields) {
			switch (f.name) {
				case "reset":
					resetFunc = f;
				case "dispose":
					disposeFunc = f;
				case "alloc":
					allocFunc = f;
				case "__pool__", "__next__", "__poolCount__", "__poolCreated__":
					Context.fatalError('${f.name} variable found for class "${className}". Unable to create object pool.',
						localClass.pos);
				default:
#if debug
					if (f.access.contains(AStatic) == false) {
						final fName = f.name;
						switch (f.kind) {
							case FFun(f):
								f.expr = macro {
									if (this.__isDisposed__ == true) {
										for (stackItem in haxe.CallStack.callStack()) {
											trace(zf.Debug.stackItemToString(stackItem));
										}
										trace("   [ObjectPool] [Warn] Using function "
											+ $v{fName} + " of disposed object " + $v{className} + ".");
									}
									${f.expr};
								}
							default:
						}
					}
#end
			}
		}

		final resetExprs = generateResetExprs();

		// add the __pool__ variable to the class
		fields.push({
			name: "__pool__",
			pos: Context.currentPos(),
			kind: FVar(Context.getLocalType().toComplexType(), null),
			access: [AStatic],
		});
		// add the __next__ variable to the class
		fields.push({
			name: "__next__",
			pos: Context.currentPos(),
			kind: FVar(Context.getLocalType().toComplexType(), null),
			access: [],
		});
		fields.push({
			name: "__poolCount__",
			pos: Context.currentPos(),
			kind: FVar(macro : Int, macro 0),
			access: [AStatic, APublic],
		});
		fields.push({
			name: "__poolCreated__",
			pos: Context.currentPos(),
			kind: FVar(macro : Int, macro 0),
			access: [AStatic, APublic],
		});
		var hasReset = false;

		{ // Check for reset method
			if (resetFunc == null) {
				if (superClass != null && TypeTools.findField(superClass, "reset") != null) {
					hasReset = true;
				}
			} else {
				hasReset = true;
			}
		}
		{ // Build Dispose Function

			/**
				There are 3 possibilities here

				1. dispose function exists in this class
				2. dispose function exists in parent(and ancestors) class but not in this class
				3. dispose function does not exists anywhere

				for 1. we will inject the code into dispose at the end of it.
				for 2. we will override dispose, call super.dispose and inject the code
				for 3. we will just add the function `dispose`
			**/
			final hasParentDispose = (superClass != null && TypeTools.findField(superClass, "dispose") != null);

			// if reset function exists, we will call it after all the @:dispose statement
			if (hasReset == true) {
				resetExprs.push(macro {
					this.reset();
				});
			}

			if (disposeFunc != null) { // case 1
				switch (disposeFunc.kind) {
					case FFun(f):
						final expr = f.expr;
						f.expr = macro {
							if (this.__isDisposed__ == true) {
#if debug
								haxe.Log.trace("   [ObjectPool] [Warn] Double disposing of object - "
									+ $v{className} + ".", null);
#end
								return;
							}
							${f.expr};
#if (debug && objectpoolmessage)
							haxe.Log.trace("   [ObjectPool] [Debug] Dispose Object - " + $v{className} + ', ${this}.',
								null);
#end
							$b{resetExprs};
							this.__isDisposed__ = true;
							this.__next__ = __pool__;
							__pool__ = this;
							__poolCount__ += 1;
						}
					default:
						Context.fatalError("dispose is not method.", disposeFunc.pos);
				}
			} else if (hasParentDispose == true) { // case 2
				fields.push({
					name: "dispose",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							if (this.__isDisposed__ == true) {
#if debug
								haxe.Log.trace("   [ObjectPool] [Warn] Double disposing of object - "
									+ $v{className} + ".", null);
#end
								return;
							}
#if (debug && objectpoolmessage)
							haxe.Log.trace("   [ObjectPool] [Debug] Dispose Object - " + $v{className} + ', ${this}.',
								null);
#end
							super.dispose();
							$b{resetExprs};
							this.__isDisposed__ = true;
							this.__next__ = __pool__;
							__pool__ = this;
							__poolCount__ += 1;
						},
						ret: macro : Void
					}),
					access: [APublic, AOverride],
				});
			} else { // case 3
				fields.push({
					name: "dispose",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							if (this.__isDisposed__ == true) {
#if debug
								haxe.Log.trace("   [ObjectPool] [Warn] Double disposing of object - "
									+ $v{className} + ".", null);
#end
								return;
							}
#if (debug && objectpoolmessage)
							haxe.Log.trace("   [ObjectPool] [Debug] Dispose Object - " + $v{className} + ', ${this}.',
								null);
#end
							$b{resetExprs};
							this.__isDisposed__ = true;
							this.__next__ = __pool__;
							__pool__ = this;
							__poolCount__ += 1;
						},
						ret: macro : Void
					}),
					access: [APublic],
				});
			}
		}
		{ // Build alloc Function
			fields.push({
				name: allocFunc == null ? "alloc" : "__alloc__",
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro {
						if (__pool__ == null) {
#if (debug && objectpoolmessage)
							haxe.Log.trace("   [ObjectPool] [Debug] New object created - " + $v{className} + ".", null);
#end
							__poolCreated__ += 1;
							return new $typePath();
						}
						__poolCount__ -= 1;
						var obj = __pool__;
						__pool__ = obj.__next__;
						obj.__next__ = null;
						obj.__isDisposed__ = false;
						return obj;
					},
					ret: Context.getLocalType().toComplexType(),
				}),
				access: [APublic, AStatic],
			});
		}
		{ // this field is here to prevent double dispose
			fields.push({
				name: "__isDisposed__",
				pos: Context.currentPos(),
				kind: FVar(macro : Bool, macro false),
				access: [APublic],
			});
		}
		return fields;
	}

	function setupDispose() {
		final fields = Context.getBuildFields();
		final localClass = Context.getLocalClass();
		final className = '${localClass}';
		final type = Context.getLocalType();
		final localClass = type.getClass();
		final typePath = {name: localClass.name, pack: localClass.pack};
		final superClass = localClass.superClass == null ? null : localClass.superClass.t.get();

		var resetFunc = null;
		var disposeFunc = null;

		for (f in fields) {
			switch (f.name) {
				case "reset":
					resetFunc = f;
				case "dispose":
					disposeFunc = f;
				default:
			}
		}

		final resetExprs = generateResetExprs();

		final hasReset = resetFunc != null || (superClass != null && TypeTools.findField(superClass, "reset") != null);

		{ // Build Dispose Function
			/**
				Similar to the original object pool, there are 3 possibilities here.

				1. dispose function exists in this class
				2. dispose function exists in parent(and ancestors) class but not in this class
				3. dispose function does not exists anywhere

				for 1. we will inject the code into dispose at the end of it.
				for 2. we will override dispose, call super.dispose and inject the code
				for 3. we will just add the function `dispose`
			**/
			final hasParentDispose = (superClass != null && TypeTools.findField(superClass, "dispose") != null);

			// if reset function exists, we will call it after all the @:dispose statement
			if (hasReset == true) {
				resetExprs.push(macro {
					this.reset();
				});
			}

			if (disposeFunc != null) { // case 1
				switch (disposeFunc.kind) {
					case FFun(f):
						final expr = f.expr;
						f.expr = macro {
							${f.expr};
							$b{resetExprs};
						}
					default:
						Context.fatalError("dispose is not method.", disposeFunc.pos);
				}
			} else if (hasParentDispose == true) { // case 2
				fields.push({
					name: "dispose",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							super.dispose();
							$b{resetExprs};
						},
						ret: macro : Void
					}),
					access: [APublic, AOverride],
				});
			} else { // case 3
				fields.push({
					name: "dispose",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							$b{resetExprs};
						},
						ret: macro : Void
					}),
					access: [APublic],
				});
			}
		}

		return fields;
	}

	public static function build(buildPool: Bool = true) {
		if (buildPool == true) {
			return new ObjectPool().setupObjectPool();
		} else {
			return new ObjectPool().setupDispose();
		}
	}
}
#end

/** Changelog
	Thu 17:06:08 25 Jul 2024
	Initial Build

	There is an argument to be made that we should automatically dispose object.
	Honestly, that feels more correct but at the same time I think that it will break CR.
	I also prefer explicit over implicit in this case, so let's just keep it this way for now.

		Fri 13:21:31 26 Jul 2024
		Adding to this note, I think we should not make it auto.
		In UI objects, disposing usually does not means disposing them, so we should definitely not
		auto dispose all the objects.

	Fri 14:31:32 26 Jul 2024
	Removed the generation of reset function if not exists.
	Instead, it now only call reset function if it exists in parent class or context class

	Fri 14:34:19 26 Jul 2024
	Should I also consider creating an ObjectPool interface that has autobuild ?
	This way we can enforce it to implements Disposable in some form

	Wed 14:31:13 21 Aug 2024
	Rename @dispose -> @:dispose

	Mon 13:16:18 02 Sep 2024
	I considered changing this to allow the generation of `dispose` without building the pool.
	This can be used by parent objects that need to dispose but cannot be alloc-ed.

	However, it is not sure if we want to generate a __reset__ or a __dispose__.

	On top of that, it might become tricky since generating reset means that the parent need to be
	generated first before the child. Too many things to considered at the moment, so parent class
	should really just handle this themselves at the moment.

	Thu 13:11:55 03 Jul 2025
	Adding to the above. I think there are some merit to it.
	we can add a flag to object pool to do this.

	Thu 13:56:07 03 Jul 2025
	BREAKING CHANGES

	__dispose__ method is no longer generated.
	Instead, if dispose is present, the code will be added to after the dispose method
	If order of disposing is important, it is better to dispose them manually.

	This is necessary to add build(false) which allow us to build dispose method without building object pool

	Another way to look at it is that
	@:dispose will generate a bunch of statements.

	If we need something to be done before these statements, create a `dispose` method and they will happen
	before the @:dispose statements.
	If we need something to be done after these statements, create a `reset` method and that method will be called
	after the @:dispose statements.

	The object pool code will always be after the reset statements
**/
