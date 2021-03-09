package zf;

/**
	Alot of time I need to wrapped existing object with an additional meta data.
	With that, I will need to create an object to do it.
	Why not just have a Wrapped data struct that wrapped a type and provide another metadata ?
**/
@:structInit class Wrapped<T, M> {
	public var data: T;
	public var metadata: M;

	public function new(data: T, metadata: M) {
		this.data = data;
		this.metadata = metadata;
	}
}
