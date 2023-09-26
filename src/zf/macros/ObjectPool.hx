package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

/**
	Object Pool is a macro-based object pool framework.

	The following fields should not exists in the class.
	- __pool__ will be created and used to store the pool
	- __next__ will be created and used to make this object a linked list

	# Dispose method
	dispose method will be added to return the object back to the pool.
	This method should not defined by the class.

	# Reset method
	reset method, called when dispose() is called to free up resource in the object.
	if not provided, an empty reset method will be created.

	# Alloc method
	alloc method to get an instance of the object. If alloc exists, __alloc__ will be created instead.
	Call __alloc__ in the custom alloc method to get the object.

	In short add the following above any class

	#if !macro
	@:build(zf.macros.ObjectPool.addObjectPool())
	#end

	This will generate something similar to

	static var __pool__: <ClassName>;
	static var __next__: <ClassName>;

	public function dispose() {}
	public function reset() {} // if reset is provided
	public function alloc() {} // if alloc is not provided
	or
	public function __alloc__() {} // if alloc exists

	# Additional notes:
	1. constructor should ideally be empty constructor, or there might be problems.
	2. object can still be created using new, and can still be dispose.
**/
class ObjectPool {
	public function new() {}

	public function setupObjectPool() {
		final fields = Context.getBuildFields();
		final className = Context.getLocalClass();
		final type = Context.getLocalType();
		final localClass = type.getClass();
		final typePath = {
			name: localClass.name,
			pack: localClass.pack
		}

		var resetFunc = null;
		var allocFunc = null;

		/**
			Check for existing function
		**/
		for (f in fields) {
			if (f.name == "reset") {
				resetFunc = f;
			} else if (f.name == "dispose") {
				trace('dispose function found for class "${className}". Unable to create object pool.');
				return fields;
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

		// add the pool variable to the class
		fields.push({
			name: "__pool__",
			pos: Context.currentPos(),
			kind: FVar(Context.getLocalType().toComplexType(), null),
			access: [AStatic],
		});

		// add the next variable to the class
		fields.push({
			name: "__next__",
			pos: Context.currentPos(),
			kind: FVar(Context.getLocalType().toComplexType(), null),
			access: [],
		});

		if (resetFunc == null) {
			trace('reset function not found for "${className}". Adding a empty reset function');

			fields.push({
				name: "reset",
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro {}, // do nothing
					ret: macro : Void,
				}),
				access: [APublic, AInline],
				doc: null,
				meta: [],
			});
		}

		// add dispose method to return it back to pool
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

		// add alloc method
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

		return fields;
	}

	public static function addObjectPool() {
		return new ObjectPool().setupObjectPool();
	}
}
#end
