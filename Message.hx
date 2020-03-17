
package common;

class Message {
    public static final TYPE = "Message";
    public var type(get, null): String;
    public function new() {}
    public function get_type(): String {
        return Message.TYPE;
    }
}

