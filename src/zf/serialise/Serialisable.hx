package zf.serialise;

/**
	@stage:stable

	See SerialiseMacro for automated generation of method
**/
interface Serialisable {
	/**
		Convert a serialisable to a struct
		@return the struct representing the object
	**/
	public function toStruct(context: SerialiseContext): Dynamic;

	/**
		Load a struct.
		@return the object itself to allow for chaining
	**/
	public function loadStruct(context: SerialiseContext, data: Dynamic): Dynamic;
}
