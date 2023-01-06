package zf.userdata;

/**
	@stage:stable
**/
interface StructData {
	public function toStruct(): Dynamic;
	public function fromStruct(data: Dynamic): Bool;
}
