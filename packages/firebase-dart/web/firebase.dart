library Firebase;

import 'dart:js';
import 'dart:async';
import 'dart:convert';

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

/**
 * A DataSnapshot contains data from a Firebase location. Any time you read
 * Firebase data, you receive data as a DataSnapshot.
 *
 * DataSnapshots are passed to event handlers such as onValue or onceValue.
 * You can extract the contents of the snapshot by calling val(), or you
 * can traverse into the snapshot by calling child() to return child
 * snapshots (which you could in turn call val() on).
 */
class DataSnapshot {
  /**
   * Holds a reference to the JavaScript 'DataSnapshot' object.
   */
  JsObject _ds;

  /**
   * Construct a new DataSnapshot from a JsObject.
   */
  DataSnapshot.fromJsObject(JsObject obj) {
    this._ds = obj;
  }

  /**
   * Get the Dart Primitive, Map or List representation of the DataSnapshot.
   * The value may be null, indicating that the snapshot is empty and contains
   * no data.
   */
  val() {
    var obj = this._ds.callMethod('val');
    var json = context['JSON'].callMethod('stringify', [obj]);
    return JSON.decode(json);
  }

  /**
   * Get a DataSnapshot for the location at the specified relative path. The
   * relative path can either bve a simple child name or a deeper slash
   * seperated path.
   */
  DataSnapshot child(String path) {
    return new DataSnapshot.fromJsObject(this._ds.callMethod('child', [path]));
  }

  /**
   * Enumerate through the DataSnapshot's children (in priority order). The
   * provided callback will be called synchronously with a DataSnapshot for
   * each child.
   */
  forEach(cb(DataSnapshot snapshot)) {
    this._ds.callMethod('forEach', [(obj) {
      cb(new DataSnapshot.fromJsObject(obj));
    }]);
  }

  /**
   * Returns true if the specified child exists.
   */
  bool hasChild(String path) {
    return this._ds.callMethod('hasChild', [path]);
  }

  /**
   * Returns true if the DataSnapshot has any children. If it does, you can
   * enumerate them with forEach. If it does not, then the snapshot either
   * contains a primitive value or it is empty.
   */
  bool hasChildren() {
    return this._ds.callMethod('hasChildren');
  }

  /**
   * Get the name of the location that generated this DataSnapshot.
   */
  String name() {
    return this._ds.callMethod('name');
  }

  /**
   * Get the number of children for this DataSnapshot. If it has children,
   * you can enumerate them with forEach().
   */
  num numChildren() {
    return this._ds.callMethod('numChildren');
  }

  /**
   * Get the Firebsae reference for the location that generated this
   * DataSnapshot.
   */
  Firebase ref() {
    return new Firebase.fromJsObject(this._ds.callMethod('ref'));
  }

  /**
   * Get the priority of the data in this DataSnapshot.
   */
  getPriority() {
    return this._ds.callMethod('getPriority');
  }

  /**
   * Exports the entire contents of the DataSnapshot as a Dart Map. This is
   * similar to val(), except priority information is included, making it
   * suitable for backing up your data.
   */
  exportVal() {
    var obj = this._ds.callMethod('exportVal');
    var json = context['JSON'].callMethod('stringify', [obj]);
    return JSON.decode(json);
  }
}

class Firebase extends Query {
  /**
   * Resolve a future, given an error and result.
   */
  void _resolveFuture(Completer c, var err, var res) {
    if (err != null) {
      c.completeError(err);
    } else {
      c.complete(res);
    }
  }

  /**
   * Construct a new Firebase reference from a full Firebase URL.
   */
  Firebase(String url) : super(url);

  /**
   * Construct a new Firebase reference from a JsObject.
   */
  Firebase.fromJsObject(JsObject obj) : super.fromJsObject(obj);

  /**
   * Authenticates a Firebase client using a provided Authentication token.
   * Takes a single token as an argument and returns a Future that will be
   * resolved when the authentication succeeds (or fails).
   */
  Future auth(String token) {
    var c = new Completer();
    this._fb.callMethod('auth', [token, (err) {
      if (err != null) {
        c.completeError(err);
      } else {
        // FIXME: Get optional second argument 'user'.
      }
    }, (err) {
      c.completeError(err);
    }]);
    return c.future;
  }

  /**
   * Unauthenticates a Firebase client (i.e. logs out).
   */
  void unauth() {
    this._fb.callMethod('unauth');
  }

  /**
   * Get a Firebase reference for a location at the specified relative path.
   * The relative path can either be a simple child name, (e.g. 'fred') or a
   * deeper slash seperated path (e.g. 'fred/name/first').
   */
  Firebase child(String path) {
    return new Firebase.fromJsObject(this._fb.callMethod('child', [path]));
  }

  /**
   * Get a Firebase reference for the parent location. If this instance refers
   * to the root of your Firebase, it has no parent, and therefore parent()
   * will return null.
   */
  Firebase parent() {
    var parentFb = this._fb.callMethod('parent');
    if (parentFb != null) {
      return new Firebase.fromJsObject(parentFb);
    } else {
      return null;
    }
  }

  /**
   * Get a Firebase reference for the root of the Firebase.
   */
  Firebase root() {
    return new Firebase.fromJsObject(this._fb.callMethod('root'));
  }

  /**
   * The last token in a Firebase location is considered its name. Calling
   * name() on any Firebase reference will return this name. Calling name()
   * on the root of a Firebase will return null.
   */
  String name() {
    return this._fb.callMethod('name');
  }

  /**
   * Write data to this Firebase location. This will overwrite any data at
   * this location and all child locations.
   *
   * The effect of the write will be visible immediately and the corresponding
   * events ('onValue', 'onChildAdded', etc.) will be triggered.
   * Synchronization of the data to the Firebase servers will also be started,
   * and the Future returned by this method will complete after synchronization
   * has finished.
   *
   * Passing null for the new value is equivalent to calling remove().
   *
   * A single set() will generate a single onValue event at the location where
   * the set() was performed.
   */
  Future set(var value) {
    var c = new Completer();
    if ((value is Map) || (value is Iterable)) {
      value = new JsObject.jsify(value);
    }
    this._fb.callMethod('set', [value, (err, res) {
      this._resolveFuture(c, err, res);
    }]);
    return c.future;
  }

  /**
   * Write the enumerated children to this Firebase location. This will only
   * overwrite the children enumerated in the 'value' parameter and will leave
   * others untouched.
   *
   * The returned Future will be complete when the synchronization has
   * completed with the Firebase servers.
   */
  Future update(var value) {
    var c = new Completer();
    if ((value is Map) || (value is Iterable)) {
      value = new JsObject.jsify(value);
    }
    this._fb.callMethod('update', [value, (err, res) {
      this._resolveFuture(c, err, res);
    }]);
    return c.future;
  }

  /**
   * Remove the data at this Firebase location. Any data at child locations
   * will also be deleted.
   *
   * The effect of this delete will be visible immediately and the
   * corresponding events (onValue, onChildAdded, etc.) will be triggered.
   * Synchronization of the delete to the Firebsae servers will also be
   * started, and the Future returned by this method will complete after the
   * synchronization has finished.
   */
  Future remove() {
    var c = new Completer();
    this._fb.callMethod('remove', [(err, res) {
      this._resolveFuture(c, err, res);
    }]);
    return c.future;
  }

  /**
   * Push generates a new child location using a unique name and returns a
   * Frebase reference to it. This is useful when the children of a Firebase
   * location represent a list of items.
   *
   * FIXME: How to implement optional argument to push(value)?
   *
   * The unique name generated by push() is prefixed with a client-generated
   * timestamp so that the resulting list will be chronologically sorted.
   */
   Firebase push() {
     return new Firebase.fromJsObject(this._fb.callMethod('push'));
   }

   /**
    * Write data to a Firebase location, like set(), but also specify the
    * priority for that data. Identical to doing a set() followed by a
    * setPriority(), except it is combined into a single atomic operation to
    * ensure the data is ordered correctly from the start.
    *
    * Returns a Future which will complete when the data has been synchronized
    * with Firebase.
    */
   Future setWithPriority(var value, var priority) {
     var c = new Completer();
     this._fb.callMethod('setWithPriority', [value, priority, (err, res) {
       this._resolveFuture(c, err, res);
     }]);
     return c.future;
   }

   /**
    * Set a priority for the data at this Firebase location. A priority can
    * be either a number or a string and is used to provide a custom ordering
    * for the children at a location. If no priorities are specified, the
    * children are ordered by name. This ordering affects the enumeration
    * order of DataSnapshot.forEach(), as well as the prevChildName parameter
    * passed to the onChildAdded and onChildMoved event handlers.
    *
    * You cannot set a priority on an empty location. For this reason,
    * setWithPriority() should be used when setting initial data with a
    * specific priority, and this function should be used when updating the
    * priority of existing data.
    */
   Future setPriority(var priority) {
     var c = new Completer();
     this._fb.callMethod('setPriority', [priority, (err, res) {
       this._resolveFuture(c, err, res);
     }]);
   }

   /**
    * Atomically modify the data at this location. Unlike a normal set(), which
    * just overwrites the data regardless of its previous value, transaction()
    * is used to modify the existing value to a new value, ensuring there are
    * no conflicts with other clients writing to the same location at the same
    * time.
    *
    * To accomplish this, you pass transaction() an update function which is
    * used to transform the current value into a new value. If another client
    * writes to the location before your new value is successfully written,
    * your update function will be called again with the new current value, and
    * the write will be retried. This will happen repeatedly until your write
    * succeeds without conflict or you abort the transaction by not returning
    * a value from your update function.
    *
    * The returned Future will be completed after the transaction has finished.
    */
   Future transaction(update(var currentVal), {bool applyLocally}) {
     var c = new Completer();
     this._fb.callMethod('transaction', [(var val) {
       return update(val);
     }, (err, committed, snapshot) {
       if (err != null) {
         c.completeError(err);
       } else {
         c.complete({
           'committed': committed,
           'snapshot': new DataSnapshot.fromJsObject(snapshot)
         });
       }
     }]);
     return c.future;
   }
}
