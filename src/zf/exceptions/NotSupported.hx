package zf.exceptions;

/**
	@stage:stable
**/
class NotSupported extends haxe.Exception {
	public function new(?previous: haxe.Exception, ?native: Any) {
		super("Not supported", previous, native);
	}
}
