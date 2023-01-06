package zf;

using zf.ds.ListExtensions;

/**
	@stage:stable

	Usage:
		MessageDispatcher.get().listen(Message.TYPE, function(m: Message) {
			trace("I received a message");
		});
		MessageDispatcher.get().dispatch(new Message());


	Non-Singleton also works

		var mailbox = new MessageDispatcher();
		mailbox.dispatch(new Message());
**/
typedef MessageDispatcherListener = {
	var id: Int;
	var messageType: String;
	var callback: Message->Void;
	var priority: Int;
}

enum DispatchMode {
	/**
		The message will be dispatched immediately.
		If the message is being dispatched in the middle of another message, it will be dispatched while the other
		is still in the middle of dispatching
	**/
	Immediately;

	/**
		The message will be dispatched after the current message is done.
		If there is no current message, it will be immediate.
	**/
	StartOfQueue;

	/**
		The message will be added to the end of the dispatch queue.
		If there is currently nothing in the queue, this it will be immediately dispatched.
	**/
	EndOfQueue;
}

class MessageDispatcher {
	/**
		Singleton Global Dispatchers
	**/
	static var Dispatchers: Map<String, MessageDispatcher> = new Map<String, MessageDispatcher>();

	/**
		Get a dispatcher by id

		@param id the id of the dispatcher
		@param create if true a new dispatcher will be created if not yet exist.
		@return the message dispatcher, or none if not found and create is `false`
	**/
	public static function get(id: String = "", create: Bool = true): MessageDispatcher {
		var d = Dispatchers.get(id);
		if (d == null && create) {
			d = new MessageDispatcher();
			Dispatchers[id] = d;
		}
		return d;
	}

	/**
		Delete a dispatcher by id

		@param id the id of the dispatcher
		@return true if found, false otherwise
	**/
	public static function delete(id: String): Bool {
		var d = Dispatchers.get(id);
		if (d == null) return false;
		Dispatchers.remove(id);
		d.clear();
		return true;
	}

	// Store all listener by id
	var listeners: Map<Int, MessageDispatcherListener>;
	// Store listener by message type
	var listenersMap: Map<String, Array<MessageDispatcherListener>>;
	// Store listeners that listen to all types of messages, example: logger
	var allMessageDispatcherListeners: Map<Int, MessageDispatcherListener>;

	// Dispatch Stack & Queued Message
	var queuedMessage: List<Message>;
	var dispatchStack: List<Message>;

	var clearing: Bool;
	var idCounter: Int = 0;

	public function new() {
		this.listeners = new Map<Int, MessageDispatcherListener>();
		this.listenersMap = new Map<String, Array<MessageDispatcherListener>>();
		this.dispatchStack = new List<Message>();
		this.queuedMessage = new List<Message>();
		this.allMessageDispatcherListeners = new Map<Int, MessageDispatcherListener>();
	}

	function clear() {
		this.listeners.clear();
		this.listenersMap.clear();
		this.allMessageDispatcherListeners.clear();
		this.queuedMessage.clear();
		this.dispatchStack.clear();
	}

	public function clearMessages() {
		this.queuedMessage.clear();
		this.dispatchStack.clear();
	}

	/**
		dispatch a message to the mailbox.

		if delayed is true, then the message will be queued and dispatched when the dispatchStack is empty.
		@param message the message to send
		@param dispatchMode when to dispatch the message.
	**/
	public function dispatch<T: Message>(message: T, dispatchMode: DispatchMode = DispatchMode.Immediately): T {
		/**
			There are 3 types of dispatchMode

			1. Dispatch immediately as part of the current dispatch, without waiting for the other listeners to finish.
			2. Dispatch after the current dispatch is done, i.e. when all the listeners is done.
			3. Add it to the end of the queue and dispatch after

			[<Message 1 listener 1>, <Message 1 listener 2>, <Message 2>]

			if a new message is dispatched as part of listener 1.

			Immediately: run it now, without waiting for listener 1 to finish, or 2 to start.
			StartOfQueue: run it after listener 2 is done
			EndOfQueue: run it after message 2
		**/

		// if nothing is currently dispatching, it will just be immediate.
		if (this.dispatchStack.length == 0) {
			dispatchMode = DispatchMode.Immediately;
		}

		if (dispatchMode == DispatchMode.StartOfQueue) {
			// if dispatch mode is start of queue, that means there is something dispatching
			// we will just add it to the start of the queue
			this.queuedMessage.push(message);
		} else if (dispatchMode == DispatchMode.EndOfQueue) {
			// if dispatch mode is end of queue, that means there is something dispatching
			// we will just add it to the end of the queue
			this.queuedMessage.add(message);
		} else { // Immediately
			_dispatchMessage(message);

			// if this message was the last message in the current dispatch stack, dispatched the queued message.
			if (this.dispatchStack.length == 0 && this.queuedMessage.length > 0 && !this.clearing) {
				this.clearing = true;
				while (this.queuedMessage.length > 0) {
					var m = this.queuedMessage.pop();
					this._dispatchMessage(m);
				}
				this.clearing = false;
			}
		}
		return message;
	}

	/**
		private function for dispatching the message
	**/
	function _dispatchMessage(message: Message) {
		this.dispatchStack.push(message);
		var listeners = this.listenersMap.get(message.type);

#if debug_message
		var t0 = Sys.time();
#end

		for (listener in this.allMessageDispatcherListeners) {
			listener.callback(message);
		}

		if (listeners != null) {
			for (listener in listeners) {
				try {
					listener.callback(message);
				} catch (e) {
					Logger.exception(e);
					throw e;
				}
			}
		}

#if debug_message
		var t1 = Sys.time();
		haxe.Log.trace('[Dispatcher] ${message} took ${(t1 - t0) * 100}ms', null);
#end

		this.dispatchStack.pop();
	}

	/**
		listen to a message and provide a callback for handling the message

		Mon 12:14:21 14 Feb 2022
		In theory we could convert this to listen<T: Message> and store the listeners
		by the classname. However, there are cases that this way of using String as
		message type is preferred.

		For example, suppose we have a message M that is used by a generic system S.
		If in a game, we want to extend the message to add new properties, but
		still want to keep S, we can extends M and S will still be able to process M
		and only in system that uses the additional properties that we need to know
		about the child class of M.

		If we use generic, then we will have to handle inheritance in this listen.
		Not that it can't be done, but it is a lot of work to handle it right now.

		@:param messageType the type value of the message
		@:param callback the function to handle the message
		@:param priority the priority for this handler, lower priority will be handled first.
	**/
	public function listen(messageType: String = "", callback: Message->Void, priority: Int = 0): Int {
		var listener = {
			id: idCounter++,
			messageType: messageType,
			callback: callback,
			priority: priority,
		}
		var functionList = this.listenersMap.get(messageType);
		if (functionList == null) {
			functionList = [];
			this.listenersMap[messageType] = functionList;
		}
		var insertIndex = functionList.length;
		for (ind => l in functionList) {
			if (l.priority > priority) {
				insertIndex = ind;
				break;
			}
		}
		functionList.insert(insertIndex, listener);
		this.listeners[listener.id] = listener;
		return listener.id;
	}

	/**
		remove a listener from the dispatcher
	**/
	public function remove(id: Int) {
		var listener = this.listeners.get(id);
		if (listener == null) {
			return;
		}

		if (listener.messageType == null) {
			this.allMessageDispatcherListeners.remove(listener.id);
		} else {
			var functionList = this.listenersMap.get(listener.messageType);
			functionList.remove(listener);
		}
		this.listeners.remove(id);
	}

	public function listenAll(callback: Message->Void): Int {
		var listener = {
			id: idCounter++,
			messageType: null,
			callback: callback,
			priority: 0,
		}
		this.allMessageDispatcherListeners[listener.id] = listener;
		this.listeners[listener.id] = listener;
		return listener.id;
	}
}
