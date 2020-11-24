package zf;

import zf.ds.List;

/**
    Previously was MessageDispatcher, now generalised to be a message dispatcher.

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
    Immediately;
    StartOfQueue;
    EndOfQueue;
}

class MessageDispatcher {
    /**
        Singleton Global Dispatchers
    **/
    static var Dispatchers: Map<String, MessageDispatcher> = new Map<String, MessageDispatcher>();

    // Get a mailbox by name;
    public static function get(id: String = "", create: Bool = true): MessageDispatcher {
        var d = Dispatchers.get(id);
        if (d == null && create) {
            d = new MessageDispatcher();
            Dispatchers[id] = d;
        }
        return d;
    }

    // Destroy a mailbox.
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
    **/
    public function dispatch(message: Message, dispatchMode: DispatchMode = DispatchMode.Immediately) {
        /**

                In theory there are 3 types of dispatch.

                1. Dispatch immediately as part of the current dispatch, without waiting for the other listeners to finish.
                2. Dispatch after the current dispatch is done, i.e. when all the listeners is done.
                3. Add it to the end of the queue and dispatch after

            [<Message 1 listener 1>, <Message 1 listener 2>, <Message 2>]

            if a new message is dispatched as part of listener 1.

            1. run it now, without waiting for listener 1 to finish, or 2 to start.
            2. run it after listener 2 is done
            3. run it after message 2

            currently, only 1 and 3 are implemented.

            This is the problem with a event/callback system. need to be extremely careful.

        **/

        // If delay is true and the stack is not empty, then we will queue it
        if (this.dispatchStack.length == 0) {
            dispatchMode = DispatchMode.Immediately;
        }

        if (dispatchMode == DispatchMode.StartOfQueue) {
            this.queuedMessage.push(message);
            return;
        } else if (dispatchMode == DispatchMode.StartOfQueue) {
            this.queuedMessage.add(message);
            return;
        } else { // Immediately
            _dispatchMessage(message);

            // if this message was the last message in the current dispatch stack,
            // dispatched the queued message.
            if (this.dispatchStack.length == 0 && this.queuedMessage.length > 0 && !this.clearing) { //
                this.clearing = true;
                while (this.queuedMessage.length > 0) {
                    var m = this.queuedMessage.pop();
                    this._dispatchMessage(m);
                }
                this.clearing = false;
            }
        }
    }

    /**
        private function for dispatching the message
    **/
    function _dispatchMessage(message: Message) {
        this.dispatchStack.push(message);
        var listeners = this.listenersMap.get(message.type);

        for (listener in this.allMessageDispatcherListeners) {
            listener.callback(message);
        }

        if (listeners != null) {
            for (listener in listeners) {
                listener.callback(message);
            }
        }

        this.dispatchStack.pop();
    }

    /**
        listen to a message and provide a callback for handling the message
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
        remove a listener from the mailbox
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
