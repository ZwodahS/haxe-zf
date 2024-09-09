package zf;

/**
	@stage:stable
**/
class Message {
#if debug
	public var debugMessages: Array<String>;
#end

	public var type(get, null): String;
	public var log(get, null): String;

#if debug
	/**
		Store the time taken for the message (in seconds)
	**/
	public var delta: Float = 0;
#end

	public function new(?type: String = "Message") {
		this.type = type;
#if debug
		this.debugMessages = [];
#end
	}

	public function get_type(): String {
		return this.type;
	}

	public function get_log(): String {
		return this.toString();
	}

	public function toString(): String {
		return '[m:${this.type}]';
	}

#if debug
	inline public function debug(message: String) {
		this.debugMessages.push(message);
	}
#end
}

/**
	A result message that is used by getResult to return results.
**/
class ResultMessage<T> extends Message implements Disposable {
	public var result: Null<T>;

	public function dispose() {
		this.result = null;
	}
}
