package zf;

/**
	@stage:stable
**/
interface StructSerialisable {
	/**
		Convert a serialisable to a struct
		@return the struct representing the object
	**/
	public function toStruct(context: SerialiseContext, option: SerialiseOption): Dynamic;

	/**
		Load a struct.
		@return the object itself to allow for chaining
	**/
	public function loadStruct(context: SerialiseContext, option: SerialiseOption, data: Dynamic): Dynamic;
}
