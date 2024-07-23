package zf;

import zf.MessageDispatcher.MessageDispatcherListener;

/**
	A simple data structure to group listeners so we can easily manage all the listeners at once.

	Usage:

	final group = new MessageListenersGroup(dispatcher);
	group.listen(....)

	To enable/disable all listeners,
	group.enable() | group.disable()

	disabling / enabling a group while messages are propagating will result in undefined behaviors.

	And to remove all listeners.
	group.remove();
**/
class MessageListenersGroup implements MessageDispatcherI {
	/**
		Store the dispatcher
	**/
	var dispatcher: MessageDispatcher;

	/**
		Store all the listeners managed by this group
	**/
	var listeners: Array<MessageDispatcherListener>;

	public function new(dispatcher: MessageDispatcher) {
		this.dispatcher = dispatcher;
		this.listeners = [];
	}

	/**
		Listen to the message and store the listener in this group
	**/
	public function listen(messageType: String, callback: Message->Void, priority: Int = 0): Int {
		final id = this.dispatcher.listen(messageType, callback, priority);
		final listener = this.dispatcher.get(id);
		this.listeners.push(listener);
		return id;
	}

	/**
		Remove all listeners from the dispatcher
	**/
	public function remove() {
		for (listener in this.listeners) {
			this.dispatcher.remove(listener.id);
		}
		this.listeners.clear();
	}

	/**
		Disable all the listeners in this group
	**/
	inline public function disable() {
		for (listener in this.listeners) listener.disabled = true;
	}

	/**
		Enable all the listeners in this group
	**/
	inline public function enable() {
		for (listener in this.listeners) listener.disabled = false;
	}
}

/**
	Tue 13:49:42 23 Jul 2024
	Added MessageListenersGroup to group listeners.

	This allows us to disable listeners when the screen is not active rather than having a flag
	in all our handlers
**/
