package zf.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Provide utility functions for handling macro.
**/
class Util {
	/**
		Check if a type is primitive
		This returns true for
		1. TAbstract for Int/Float/Bool
		2. TAbstract where it is enum representation of Int/Float/Bool/String
		3. TInst String
	**/
	public static function isPrimitive(type: haxe.macro.Type): Bool {
		switch (type) {
			case TInst(_.get() => t, p):
				switch (t.name) {
					case "String":
						return true;
					default:
						return false;
				}
			case TAbstract(_.get() => t, p):
				switch (t.name) {
					case "Int", "Float", "Bool":
						return true;
					case "Null":
						if (p.length == 0) return false;
						return isPrimitive(p[0]);
					default:
						/**
							Sat 16:04:07 13 Jul 2024
							Not sure if this is enough to handle it, but this takes care of
							any enum abstract int/string/float
						**/
						return isPrimitive(t.type);
				}
			case TDynamic(_):
				return false;
			default:
				return false;
		}
		return false;
	}

	public static function isObject(type: haxe.macro.Type): Bool {
		switch (type) {
			case TInst(_.get() => t, p):
				switch (t.name) {
					case "String":
						return false;
					default:
						return true;
				}
			default:
				return false;
		}
	}

	public static function isDynamic(type: haxe.macro.Type): Bool {
		switch (type) {
			case TDynamic(_):
				return true;
			default:
				return false;
		}
	}

	public static function isArray(type: haxe.macro.Type): Bool {
		switch (type) {
			case TInst(_.get() => t, p):
				switch (t.name) {
					case "Array":
						return true;
					default:
				}
			default:
		}
		return false;
	}

	public static function getArrayType(type: haxe.macro.Type): haxe.macro.Type {
		switch (type) {
			case TInst(_.get() => t, p):
				switch (t.name) {
					case "Array":
						if (p.length == 0) return null;
						return p[0];
					default:
				}
			default:
		}
		return null;
	}

	/**
		Check if a type is an enum
	**/
	public static function isEnum(type: haxe.macro.Type): Bool {
		switch (type) {
			case TEnum(_, _):
				return true;
			default:
		}
		return false;
	}

	/**
		Check if a var type is function
	**/
	public static function isFunction(type: haxe.macro.Type): Bool {
		switch (type) {
			case TFun(_, _):
				return true;
			default:
		}
		return false;
	}

	public static function hasInterface(type: haxe.macro.Type.ClassType, inf: String) {
		for (i in type.interfaces) {
			if (i.t.get().name == inf) return true;
		}
		if (type.superClass != null) {
			return hasInterface(type.superClass.t.get(), inf);
		}
		return false;
	}

	public static function isChildOf(type: haxe.macro.Type.ClassType, parent: haxe.macro.Type.ClassType) {
		var current = type;
		while (current != null) {
			if (current?.module == parent.module) return true;
			current = current.superClass?.t.get();
		}
		return false;
	}

	public static function getMeta(meta: haxe.macro.Expr.Metadata, name: String): haxe.macro.Expr.MetadataEntry {
		if (meta == null) return null;
		for (m in meta) {
			if (m.name == name) return m;
		}
		return null;
	}

	public static function getTypeOfField(type: haxe.macro.Type, fieldName: String): haxe.macro.Type {
		switch (type) {
			case TType(t, _):
				return getTypeOfField(t.get().type, fieldName);
			case TAnonymous(t):
				final aType = t.get();
				for (f in aType.fields) {
					if (f.name == fieldName) return f.type;
				}
				return null;
			default:
		}
		return null;
	}

	public static function getType(name: String): haxe.macro.Type {
		try {
			return haxe.macro.Context.getType(name);
		} catch (e) {
			return null;
		}
	}
}
#end
