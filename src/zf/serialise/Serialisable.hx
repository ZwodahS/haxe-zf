package zf.serialise;

/**
	See SerialiseMacro for automated generation of method
**/
interface Serialisable {
	/**
		Convert a serialisable to a struct

		@param context the SerialiseContext
		@param struct the struct to serialise to.

		@return the struct representing the object
	**/
	public function toStruct(context: SerialiseContext, struct: Dynamic = null): Dynamic;

	/**
		Load a struct.

		@param context the SerialiseContext
		@param struct the struct to serialise from.

		@return the object itself to allow for chaining
	**/
	public function loadStruct(context: SerialiseContext, struct: Dynamic): Dynamic;
}

/**
	Wed 14:26:11 09 Jul 2025
	change toStruct signature from
		toStruct(SerialiseContext): Dynamic
	to
		toStruct(SerialiseContext, Dynamic = null): Dynamic

	This change is to facilitate the changes needed for SerialiseMacro
**/
