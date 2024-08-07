package zf;

using zf.ds.ListExtensions;

/**
	@stage:stable
**/
typedef MessageDispatcherListener = {
	public var id: Int;
	public var messageType: String;
	public var callback: Message->Void;
	public var priority: Int;
	public var disabled: Bool;
}

/**
	The mode for dispatching the message
**/
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

/**
	A message dispatcher that dispatch messages to listeners
**/
class MessageDispatcher implements MessageDispatcherI {
	// Store all listener by id
	var listeners: Map<Int, MessageDispatcherListener>;
	// Store listener by message type
	var listenersMap: Map<String, Array<MessageDispatcherListener>>;
	// Store listeners that listen to all types of messages, example: logger
	var allMessageDispatcherListeners: Map<Int, MessageDispatcherListener>;

	// Dispatch Stack & Queued Message
	var queuedMessage: List<Message>;
	var dispatchStack: List<Message>;

	/**
		Store a flag to ensure that we will not be clearing the queue while we are clearing the queue
	**/
	var isClearing: Bool = false;

	/**
		Id counter to generate id for all listeners.
	**/
	var idCounter: Int = 0;

	public function new() {
		this.listeners = new Map<Int, MessageDispatcherListener>();
		this.listenersMap = new Map<String, Array<MessageDispatcherListener>>();
		this.dispatchStack = new List<Message>();
		this.queuedMessage = new List<Message>();
		this.allMessageDispatcherListeners = new Map<Int, MessageDispatcherListener>();
	}

	/**
		Clear all listener from this dispatcher
	**/
	function clear() {
		this.listeners.clear();
		this.listenersMap.clear();
		this.allMessageDispatcherListeners.clear();
		this.queuedMessage.clear();
		this.dispatchStack.clear();
	}

	/**
		Clear all messages from both dispatch stack and queue.

		WARN: This should never be used normally since messages will not be handled properly.
	**/
	public function clearMessages() {
		this.queuedMessage.clear();
		this.dispatchStack.clear();
	}

	/**
		Dispatch a message to all the listeners.

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
			// we will dispatch the messages immediately.
			// while this is dispatching, the dispatch stack will add the message to the start/top of dispatch stack.
			// when this exits, the first/top item on the dispatch stack should not be this message
			_dispatchMessage(message);
			Assert.assert(this.dispatchStack.length == 0 || this.dispatchStack.first() != message);

			// if this message is the last message on the current stack, dispatch all the queued messages.
			if (this.dispatchStack.length == 0 && this.queuedMessage.length > 0 && !this.isClearing) {
				// isClearing flag is set so that we will only have 1 `dispatch` method clearing the queued messages.
				this.isClearing = true;
				while (this.queuedMessage.length > 0) {
					final m = this.queuedMessage.pop();
					/**
						Note that while dispatching messages, new messages may either be added to the queue
						or is dispatched immediately.

						This is handled, since if it is immediate, it will be added to the dispatch stack.
						If it is not immediate, then it will be added to the queue, and it will be handed by
						this loop that is clearing the messages.
					**/
					this._dispatchMessage(m);
				}
				this.isClearing = false;
			}
		}
		return message;
	}

	/**
		Actual dispatch logic

		This should not be called directly.

		When dispatching the message, the message will be added to the dispatch stack.
		After this dispatching is completed, it will be removed from the stack.
	**/
	function _dispatchMessage(message: Message) {
		this.dispatchStack.push(message);
		final listeners = this.listenersMap.get(message.type);

		onBeforeMessage(message);

#if (debug && sys)
		final t0 = Sys.time();
		message.debug('(Initial) ${message}');
#end

		for (listener in this.allMessageDispatcherListeners) {
			if (listener.disabled == true) continue;
			// dispatch the messages to all message dispatchers first.
			// this really shouldn't be used except for debugging purpose.

#if debug
			var callbackTime = .0;
#end
#if (debug && sys)
			final tt0 = Sys.time();
#end

			// this is the only actual logic, the block above and below is just debugging and logging
			listener.callback(message);

#if (debug && sys)
			final delta = Sys.time() - tt0;
			callbackTime = delta;
#end
#if debug
			final callbackTimeString = callbackTime == 0 ? '' : ', Took ${callbackTime * 100}ms';
			message.debug('(After [AllListener: ${listener.id}|(${listener.priority})]) ${message}${callbackTimeString}');
#end
		}

		// dispatch the messages to the listeners of this message
		if (listeners != null) {
			for (listener in listeners) {
				if (listener.disabled == true) continue;
				try {
#if debug
					var callbackTime = .0;
#end
#if (debug && sys)
					final tt0 = Sys.time();
#end

					// this is the only actual logic, the block above and below is just debugging and logging
					listener.callback(message);

#if (debug && sys)
					final delta = Sys.time() - tt0;
					callbackTime = delta;
#end
#if debug
					final callbackTimeString = callbackTime == 0 ? '' : ', Took ${callbackTime * 100}ms';
					message.debug('(After [Listener: ${listener.id}|(${listener.priority})]) ${message}${callbackTimeString}');
#end
				} catch (e) {
					Logger.exception(e);
					throw e;
				}
			}
		}

#if debug
		message.debug('(OnFinish) ${message}');
#end

#if (debug && sys)
		final delta = Sys.time() - t0;
		message.delta = delta;
		message.debug('(Time Taken) ${delta * 100}ms');
#end

		onAfterMessage(message);

		this.dispatchStack.pop();
	}

	dynamic public function onBeforeMessage(m: Message) {}

	dynamic public function onAfterMessage(m: Message) {}

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

		Wed 15:42:04 07 Aug 2024
		Adding to this note.

		I have added a lot of macro recently and I was wondering if I can do better
		for messages. I could add MessageType to all child of message via macro,
		and I could also extend this to accept Message object.

		However, all these doesn't do much to make things better than what I already
		have, i.e. Snippet to create Message. So .. Future Me, don't try, or rather
		there is no gain here. Unless you discover a reason to.

		@:param messageType the type value of the message
		@:param callback the function to handle the message
		@:param priority the priority for this handler, lower priority will be handled first.
	**/
	public function listen(messageType: String, callback: Message->Void, priority: Int = 0): Int {
		final listener = {
			id: idCounter++,
			messageType: messageType,
			callback: callback,
			priority: priority,
			disabled: false,
		}

		// create the listener list if not already created.
		var listeners = this.listenersMap.get(messageType);
		if (listeners == null) {
			listeners = [];
			this.listenersMap[messageType] = listeners;
		}

		// find where to insert the listener.
		var insertIndex = listeners.length;
		for (ind => l in listeners) {
			if (l.priority > priority) {
				insertIndex = ind;
				break;
			}
		}

		// add the listener
		listeners.insert(insertIndex, listener);
		this.listeners[listener.id] = listener;

		return listener.id;
	}

	inline public function get(id: Int): MessageDispatcherListener {
		return this.listeners.get(id);
	}

	/**
		remove a listener from the dispatcher by id

		@:param id the listener id provided when listen is called.
	**/
	public function remove(id: Int) {
		final listener = this.listeners.get(id);
		if (listener == null) return;

		if (listener.messageType == null) {
			// if message is the all listener, then we remove it from the all message listener
			this.allMessageDispatcherListeners.remove(listener.id);
		} else {
			// remove it from the specific message listeners.
			final listeners = this.listenersMap.get(listener.messageType);
			Assert.assert(listeners != null);
			listeners.remove(listener);
		}
		this.listeners.remove(id);
	}

	/**
		Listen to all messages.

		@:param callback the callback function.
		@:return the listener id
	**/
	public function listenAll(callback: Message->Void): Int {
		final listener: MessageDispatcherListener = {
			id: idCounter++,
			messageType: null,
			callback: callback,
			priority: 0,
			disabled: false,
		}
		this.allMessageDispatcherListeners[listener.id] = listener;
		this.listeners[listener.id] = listener;
		return listener.id;
	}
}

/**
	Tue 12:56:43 23 Jul 2024
	Removing the global method to get a dispatcher.
	This has never been used, and I highly doubt I will use it ever.
**/
