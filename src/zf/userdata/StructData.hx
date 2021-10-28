package zf.userdata;

interface StructData {
	public function toStruct(): Dynamic;
	public function fromStruct(data: Dynamic): Bool;
}
