package zf.exceptions;

/**
	@stage:stable
**/
class SerialiseException extends haxe.Exception {
	public var reason: String;

	public function new(reason: String, ?previous: haxe.Exception, ?native: Any) {
		super('SerialiseException: ${reason}', previous, native);
		this.reason = reason;
	}
}
