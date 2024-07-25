package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;

using haxe.macro.Tools;
using haxe.macro.TypeTools;

/**
	Object Pool is a macro-based object pool framework.

	The following fields should not exists in the class.
	- __pool__ will be created and used to store the pool
	- __next__ will be created and used to make this object a linked list

	- dispose or __dispose__
	dispose method will be added to return the object back to the pool.
	if this method is defined by class, __dispose__ will be created instead
	if this method is defined by parent but not current class, __dispose__ will be created,
		a dispose method will also be created calling super.dispose and __dispose__.

	- reset
	if reset method is present (in parent or child), it will be called when the object is disposed.

	- alloc or __alloc__
	alloc method to get an instance of the object.
	If alloc exists, __alloc__ will be created instead.
	Call __alloc__ in the custom alloc method to get the object.

	# Usage
	#if !macro @:build(zf.macros.ObjectPool.addObjectPool()) #end
	class XXX {}

	## Field metadata

	### 1. @dispose
	@dispose generates the code used to dispose the field.

	@dispose(type, ...)

	type - "all" (default) (T0) (TOe)
	This disposes the field "smartly" based on the rules belows
	1. For primitive|enum|function, it will be handled like type-"set" and a default value is needed.
	2. For object with dispose function, call dispose then set it to null
	For Array - See note below

	type - "func" (T1)
	Call a function on the object.
	For example @dispose("func", "clear") will call the clear function of the object
	This will not set the value of the field

	type - "set" (T2)
	Set the value of field to the default value provided.
	If an additional value is provided in the second params of @dispose
	then it will be set to the second params of @dispose

	@dispose("set") public var x: Int = 0;
	will dispose it to 0.

	@dispose("set", 0) public var x: Int;
	will also dispose it to 0

	Dealing with array.
	There are a few cases usually with array

	1. Clear the array without updating the field.
	2. Set the field to null
	3. Call "dispose" on all items in array, then empty the array
	4. Call "dispose" on all items in array, then set array to null

	Case 1 is handled via (AO1)
	@dispose("func", "clear") public var arr: Array<Object>;
	Case 2 is handled via (AO2)
	@dispose("set") public var arr: Array<Object> = null;
	Case 3 is handled via (AO3)
	@dispose public var arr: Array<Object>;
	Case 4 is handled via (AO4)
	@dispose public var arr: Array<Object> = null;

	In both AO3 and AO4, the array will be cleared, since the objects are disposed

	Because Array can also contains primitive or object that cannot be disposed
	case 1 can be handled by @dispose for primitive case via (AP1)
	@dispose public var arr: Array<Int>;

	case 2 can be handled by @dispose for primitive case via (AP2)
	@dispose public var arr: Array<Int> = null;

	# Additional notes:
	1. constructor of the object need to be empty.
	2. object can still be created using new, and can still be dispose, not sure why we will do that.
	3. ObjectPool object should not be extended.
	4. Using @dispose on object with dispose function but is not Disposable will not work.

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
						|| Util.hasInterface(type.getClass(), "Disposable") == false) {
						generateSet(f, e);
					} else { // dispose function exists
						if (e != null && explicit == false) {
							Context.info('[Warn] ${fieldName} is Disposable with a default value. Intended ?', f.pos);
						}
						generateDisposeSetNull(f, e);
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
						this.$fieldName.$funcName();
					});
				default:
					Context.fatalError('${f.name} cannot be disposed.', f.pos);
			}
		}

		function handleSetDispose(f: haxe.macro.Field, value: Expr) {
			if (value == null) {
				switch (f.kind) {
					case FVar(_.toType() => type, e):
						if (e == null) Context.fatalError('${f.name} requires a default value or a set value.', f.pos);
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
			final meta = Util.getMeta(f.meta, "dispose");
			if (meta == null) continue;

			if (meta.params.length == 0) { // T0
				handleFullDispose(f);
			} else if (meta.params[0].getValue() == "all") { // T0e
				handleFullDispose(f, true);
			} else if (meta.params[0].getValue() == "func") { // T1
				if (meta.params.length < 2) Context.fatalError('@dispose("func") requires a function name', f.pos);
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
		final className = Context.getLocalClass();
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
			if (f.name == "reset") {
				resetFunc = f;
			} else if (f.name == "dispose") {
				disposeFunc = f;
			} else if (f.name == "__pool__") {
				Context.fatalError('__pool__ variable found for class "${className}". Unable to create object pool.',
					localClass.pos);
			} else if (f.name == "__next__") {
				Context.fatalError('__next__ variable found for class "${className}". Unable to create object pool.',
					localClass.pos);
			} else if (f.name == "alloc") {
				allocFunc = f;
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

		var hasReset = false;
		{ // Build Reset Function
			if (resetFunc == null) {
				if (superClass != null && TypeTools.findField(superClass, "reset") != null) {
					// if parent has reset, we don't need to add it.
					hasReset = true;
				} else {
					// reset method don't exists
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

				for 1. we will add a __dispose__ and be done with it
				for 2. we will add a __dispose__ and also a dispose function that call super.dispose and __dispose__
				for 3. we will add the function as dispose

				Tue 13:58:32 09 Jul 2024
				There is a better way to write this without duplicating code.
				However, it also makes it harder to read, so don't change it
			**/
			final hasParentDispose = (superClass != null && TypeTools.findField(superClass, "dispose") != null);

			if (hasReset == true) {
				resetExprs.push(macro {
					this.reset();
				});
			}

			if (disposeFunc != null) { // case 1
				fields.push({
					name: "__dispose__",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							$b{resetExprs};
							this.__next__ = __pool__;
							__pool__ = this;
						},
						ret: macro : Void
					}),
					access: [APublic, AInline],
				});
			} else if (hasParentDispose == true) { // case 2
				fields.push({
					name: "__dispose__",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							$b{resetExprs};
							this.__next__ = __pool__;
							__pool__ = this;
						},
						ret: macro : Void
					}),
					access: [APublic, AInline],
				});
				fields.push({
					name: "dispose",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							super.dispose();
							__dispose__();
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
							this.__next__ = __pool__;
							__pool__ = this;
						},
						ret: macro : Void
					}),
					access: [APublic, AInline],
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
							return new $typePath();
						}
						var obj = __pool__;
						__pool__ = obj.__next__;
						obj.__next__ = null;

						return obj;
					},
					ret: Context.getLocalType().toComplexType(),
				}),
				access: [APublic, AStatic, AInline],
			});
		}

		return fields;
	}

	public static function addObjectPool() {
		return new ObjectPool().setupObjectPool();
	}

	public static function build() {
		return new ObjectPool().setupObjectPool();
	}
}
#end

/**
	Sun 14:39:14 05 May 2024
	Added back zf.ObjectPool to handle a more simple way to handle object pool for objects
	that I can't extend.
	Another note, this does not have maxPoolSize. At the moment not sure if I need it.

	Thu 17:06:08 25 Jul 2024
	Added @dispose meta to dispose object
	There is an argument to be made that we should automatically dispose object.
	Honestly, that feels more correct but at the same time I think that it will break CR.
	I also prefer explicit over implicit in this case, so let's just keep it this way for now.

		Fri 13:21:31 26 Jul 2024
		Adding to this note, I think we should not make it auto.
		In UI objects, disposing usually does not means disposing them, so we should definitely not
		auto dispose all the objects.

	Fri 13:21:04 26 Jul 2024
	Should I split "all" into "all" and "auto" ?

	Fri 14:31:32 26 Jul 2024
	Removed the generation of reset function if not exists.
	Instead, it now only call reset function if it exists in parent class or context class

	Fri 14:34:19 26 Jul 2024
	Should I also consider creating an ObjectPool interface that has autobuild ?
	This way we can enforce it to implements Disposable in some form
**/
