part of Firebase;

/**
 * An Event is an object that is provided by every Stream on the query
 * object. It is simply a wrapper for a tuple of DataSnapshot and PrevChild.
 * Some events (like added, moved or changed) have a prevChild argument
 * that is the name of the object that is before the object referred by the
 * event in priority order.
 */
class Event {
  DataSnapshot snapshot;
  String prevChild;
  Event(this.snapshot, this.prevChild);
}

/**
 * A Query filters the data at a Firebase location so only a subset of the
 * child data is visible to you. This can be used for example to restrict a
 * large list of items down to a number suitable for synchronizing to the
 * client.
 *
 * Queries are created by chaining together one or two of the following filter
 * functions: startAt(), endAt() and limit().
 *
 * Once a Query is constructed, you can receive data for it using on(). You
 * will receive
 */
class Query {
  /**
   * Holds a reference to the JavaScript 'Firebase' object.
   */
  JsObject _fb;
  Stream<Event> _onValue = null;
  Stream<Event> _onChildAdded = null;
  Stream<Event> _onChildMoved = null;
  Stream<Event> _onChildChanged = null;
  Stream<Event> _onChildRemoved = null;

  /**
   * Construct a new default Query for a given URL.
   */
  Query (String url) {
    this._fb = new JsObject(context['Firebase'], [url]);
  }

  /**
   * Construct a new Query from a JsObject.
   */
  Query.fromJsObject(JsObject obj) {
    this._fb = obj;
  }

  /**
   * Helper function to create a new stream for a particular event type.
   */
  Stream<Event> _createStream(String type) {
    StreamController<Event> controller;
    void startListen() {
      this._fb.callMethod('on', [type, (snapshot, prevChild) {
        controller.add(
            new Event(new DataSnapshot.fromJsObject(snapshot), prevChild));
      }]);
    }
    void stopListen() {
      this._fb.callMethod('off', [type]);
    }
    controller = new StreamController<Event>.broadcast(
        onListen: startListen,
        onCancel: stopListen);
    return controller.stream;
  }

  /**
   * Streams for various data events.
   */
  Stream<Event> get onValue {
    if (this._onValue != null) {
      return this._onValue;
    }
    this._onValue = this._createStream('value');
    return this._onValue;
  }

  Stream<Event> get onChildAdded {
    if (this._onChildAdded != null) {
      return this._onChildAdded;
    }
    this._onChildAdded = this._createStream('child_added');
    return this._onChildAdded;
  }

  Stream<Event> get onChildMoved {
    if (this._onChildMoved != null) {
      return this._onChildMoved;
    }
    this._onChildMoved = this._createStream('child_moved');
    return this._onChildMoved;
  }

  Stream<Event> get onChildChanged {
    if (this._onChildChanged != null) {
      return this._onChildChanged;
    }
    this._onChildChanged = this._createStream('child_changed');
    return this._onChildChanged;
  }

  Stream<Event> get onChildRemoved {
    if (this._onChildRemoved != null) {
      return this._onChildRemoved;
    }
    this._onChildRemoved = this._createStream('child_removed');
    return this._onChildRemoved;
  }

  /**
   * Generate a Query object limited to the number of specified children. If
   * combined with startAt, the query will include the specified number of
   * children after the starting point. If combined with endAt, the query will
   * include the specified number of children before the ending point. If not
   * combined with startAt() or endAt(), the query will include the last
   * specified number of children.
   */
  Query limit(num limit) {
    return new Query.fromJsObject(this._fb.callMethod('limit', [limit]));
  }

  /**
   * Create a Query with the specified starting point. The starting point is
   * specified using a priority and an optinal child name. If no arguments
   * are provided, the starting point will be the beginning of the data.
   *
   * The starting point is inclusive, so children with exactly the specified
   * priority will be included. Though if the optional name is specified, then
   * the children that have exactly the specified priority must also have a
   * name greater than or equal to the specified name.
   *
   * startAt() can be combined with endAt() or limit() to create further
   * restrictive queries.
   */
  Query startAt({var priority, var name}) {
    return new Query.fromJsObject(this._fb.callMethod('startAt',
                                                      [priority, name]));
  }

  /**
   * Create a Query with the specified ending point. The ending point is
   * specified using a priority and an optional child name. If no arguments
   * are provided, the ending point will be the end of the data.
   *
   * The ending point is inclusive, so children with exactly the specified
   * priority will be included. Though if the optional name is specified, then
   * children that have exactly the specified priority must also have a name
   * less than or equal to the specified name.
   *
   * endAt() can be combined with startAt() or limit() to create further
   * restrictive queries.
   */
  Query endAt({var priority, var name}) {
    return new Query.fromJsObject(this._fb.callMethod('endAt',
                                                      [priority, name]));
  }

  /**
   * Queries are attached to a location in your Firebase. This method will
   * return a Firebase reference to that location.
   */
  Firebase ref() {
    return new Firebase.fromJsObject(this._fb.callMethod('ref'));
  }
}
