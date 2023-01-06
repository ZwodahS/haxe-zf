package zf.exceptions;

import haxe.Exception;

/**
	@stage:stable
**/
class ResourceLoadException extends Exception {
	public var path: String;

	public function new(path: String, ?previous: Exception, ?native: Any) {
		this.path = path;
		super('Fail to load resource: ${path}', previous, native);
	}
}
