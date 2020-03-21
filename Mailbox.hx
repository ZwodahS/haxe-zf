package common;

/**

A simple messaging system.
Usually used in ECS for sending message between systems.
This is also useful for sending events or building event based architecture.

Usage:

    Mailbox.get().listen(Message.TYPE, function(m: Message) {
        trace("I received a message");
    });

    Mailbox.get().dispatch(new Message());

**/

/**
  Common Message for all messages
**/
typedef Listener = {
    var id: Int;
    var messageType: String;
    var callback: Message -> Void;
}

/**
  Mailbox object.
  Use this to dispatch messages or listen to messages.
**/

enum DispatchMode {
    Immediately;
    StartOfQueue;
    EndOfQueue;

}

class Mailbox {

    static var MAILBOXES: Map<String, Mailbox> = new Map<String, Mailbox>();
    static var COUNTER: Int = 0;

    // Get a mailbox by name;
    public static function get(id: String = "", create: Bool=true): Mailbox {
        var mb = MAILBOXES.get(id);
        if (mb == null && create) {
            mb = new Mailbox();
            MAILBOXES[id] = mb;
        }
        return mb;
    }

    var listeners: Map<Int, Listener>;
    var listenersMap: Map<String, List<Listener>>;

    var queuedMessage: List<Message>;
    var dispatchStack: List<Message>;

    var clearing: Bool;

    public function new() {
        this.listeners = new Map<Int, Listener>();
        this.listenersMap = new Map<String, List<Listener>>();
        this.dispatchStack = new List<Message>();
        this.queuedMessage = new List<Message>();
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
        }
        else if (dispatchMode == DispatchMode.StartOfQueue) {
            this.queuedMessage.add(message);
            return;

        } else { // Immediately
            _dispatchMessage(message);

            // if this message was the last message in the current dispatch stack,
            // dispatched the queued message.
            if (this.dispatchStack.length == 0 && this.queuedMessage.length > 0 && !this.clearing){ //
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
    public function listen(messageType: String = "", callback: Message->Void): Int {
        var listener = {
            id: COUNTER++,
            messageType: messageType,
            callback: callback,
        }
        var functionList = this.listenersMap.get(messageType);
        if (functionList == null) {
            functionList = new List<Listener>();
            this.listenersMap[messageType] = functionList;
        }
        functionList.add(listener);
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

        // should never be null
        var functionList = this.listenersMap.get(listener.messageType);

        functionList.remove(listener);
        this.listeners.remove(id);
    }
}

