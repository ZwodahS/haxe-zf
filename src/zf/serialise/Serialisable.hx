package zf.serialise;

/**
	@stage:stable
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

/**
	Fri 14:56:14 10 Nov 2023
	Note to self:

	Tried to do something similar to json2object with macro to auto create the toStruct and loadStruct.
	I will have to try do this later again.
	There is a branch that do this, maybe revisit later
**/
