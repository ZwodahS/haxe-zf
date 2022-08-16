package zf.exceptions;

class NotImplemented extends haxe.Exception {
	public function new(?previous: haxe.Exception, ?native: Any) {
		super("Not implemented", previous, native);
	}
}
