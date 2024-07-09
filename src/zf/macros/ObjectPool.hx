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

	- dispose
	dispose method will be added to return the object back to the pool.
	if this method is defined by class, __dispose__ will be created instead
	if this method is defined by parent, __dispose__ will be created, and a dispose method will also be created
	calling super.dispose and __dispose__.

	- reset
	reset method, called when dispose() is called to free up resource in the object.
	if not provided and parent does not have reset, an empty reset method will be created.

	- alloc
	alloc method to get an instance of the object.
	If alloc exists, __alloc__ will be created instead.
	Call __alloc__ in the custom alloc method to get the object.

	# Usage
	#if !macro @:build(zf.macros.ObjectPool.addObjectPool()) #end
	class XXX {}

	# Summary
	This will generate something similar to

	static var __pool__: <ClassName>;
	static var __next__: <ClassName>;

	public function dispose() {}
	public function reset() {} // if reset is provided
	public function alloc() {} // if alloc is not provided
	or
	public function __alloc__() {} // if alloc exists

	# Additional notes:
	1. constructor of the object need to be empty.
	2. object can still be created using new, and can still be dispose, not sure why we will do that.
	3. ObjectPool object should not be extended.
**/
class ObjectPool {
	public function new() {}

	public function setupObjectPool() {
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
				trace('__pool__ variable found for class "${className}". Unable to create object pool.');
				return fields;
			} else if (f.name == "__next__") {
				trace('__next__ variable found for class "${className}". Unable to create object pool.');
				return fields;
			} else if (f.name == "alloc") {
				allocFunc = f;
			}
		}

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

		{ // Build Reset Function
			if (resetFunc == null) {
				final access = [APublic];
				if (superClass != null && TypeTools.findField(superClass, "reset") != null) {
					access.push(AOverride);
				} else {
					access.push(AInline);
				}

				fields.push({
					name: "reset",
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {}, // do nothing
						ret: macro : Void,
					}),
					access: access,
					doc: null,
					meta: [],
				});
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

			if (disposeFunc != null) { // case 1
				fields.push({
					name: "__dispose__",
					doc: null,
					meta: [],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro {
							this.reset();
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
							this.reset();
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
							this.reset();
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
}
#end

/**
	Sun 14:39:14 05 May 2024
	Added back zf.ObjectPool to handle a more simple way to handle object pool for objects
	that I can't extend.
	Another note, this does not have maxPoolSize. At the moment not sure if I need it.
**/
