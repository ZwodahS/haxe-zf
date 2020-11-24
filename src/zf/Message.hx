package zf;

class Message {
    public static final TYPE = "Message";

    public var type(get, null): String;
    public var log(get, null): String;

    public function new() {}

    public function get_type(): String {
        return Message.TYPE;
    }

    public function get_log(): String {
        return '${this.type}';
    }

    public function toString(): String {
        return '${this.type}';
    }
}
