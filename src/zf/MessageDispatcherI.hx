package zf;

interface MessageDispatcherI {
	public function listen(messageType: String, callback: Message->Void, priority: Int = 0): Int;
	public function removeListener(id: Int): Void;
}
