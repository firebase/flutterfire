part of Firebase;

/**
 * An Event is an object that is provided by every Stream on the query
 * object. It is simply a wrapper for a tuple of DataSnapshot and PrevChild.
 * Some events (like added, moved or changed) have a prevChild argument
 * that is the name of the object that is before the object referred by the
 * event in priority order.
 */
class Event {
  final DataSnapshot snapshot;
  final String prevChild;
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
  Stream<Event> _onValue;
  Stream<Event> _onChildAdded;
  Stream<Event> _onChildMoved;
  Stream<Event> _onChildChanged;
  Stream<Event> _onChildRemoved;

  /**
   * Construct a new default Query for a given URL.
   */
  Query(String url): _fb = new JsObject(context['Firebase'], [url]);

  /**
   * Construct a new Query from a JsObject.
   */
  Query.fromJsObject(JsObject obj): _fb = obj;

  /**
   * Helper function to create a new stream for a particular event type.
   */
  Stream<Event> _createStream(String type) {
    StreamController<Event> controller;
    void startListen() {
      _fb.callMethod('on', [type, (snapshot, prevChild) {
        controller.add(
            new Event(new DataSnapshot.fromJsObject(snapshot), prevChild));
      }]);
    }
    void stopListen() {
      _fb.callMethod('off', [type]);
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
    if (_onValue == null) {
      _onValue = this._createStream('value');
    }
    return _onValue;
  }

  Stream<Event> get onChildAdded {
    if (_onChildAdded == null) {
      _onChildAdded = this._createStream('child_added');
    }
    return _onChildAdded;
  }

  Stream<Event> get onChildMoved {
    if (_onChildMoved == null) {
      _onChildMoved = this._createStream('child_moved');
    }
    return _onChildMoved;
  }

  Stream<Event> get onChildChanged {
    if (_onChildChanged == null) {
      _onChildChanged = this._createStream('child_changed');
    }
    return _onChildChanged;
  }

  Stream<Event> get onChildRemoved {
    if (_onChildRemoved == null) {
      _onChildRemoved = this._createStream('child_removed');
    }
    return _onChildRemoved;
  }

  /**
   * Generate a Query object limited to the number of specified children. If
   * combined with startAt, the query will include the specified number of
   * children after the starting point. If combined with endAt, the query will
   * include the specified number of children before the ending point. If not
   * combined with startAt() or endAt(), the query will include the last
   * specified number of children.
   */
  Query limit(int limit) =>
      new Query.fromJsObject(_fb.callMethod('limit', [limit]));

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
  Query startAt({int priority, String name}) => new Query.fromJsObject(_fb.callMethod('startAt', _removeNulls([priority, name])));

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
  Query endAt({int priority, String name}) => new Query.fromJsObject(_fb.callMethod('endAt', _removeNulls([priority, name])));

  /**
   * Queries are attached to a location in your Firebase. This method will
   * return a Firebase reference to that location.
   */
  Firebase ref() => new Firebase.fromJsObject(_fb.callMethod('ref'));
}
