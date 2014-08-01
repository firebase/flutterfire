library Firebase;

import 'dart:js';
import 'dart:async';
import 'dart:convert';

part 'src/firebase/query.dart';
part 'src/firebase/snapshot.dart';
part 'src/firebase/disconnect.dart';

List _removeNulls(List args) {
  args.removeWhere((args) => args == null);
  return args;
}

/**
 * A successful authentication response.
 */
class AuthResponse {
  final int expires;
  final String auth;

  AuthResponse(JsObject response)
      : expires = response['expires'],
        auth = response['auth'];

  String toString() => 'expires: $expires, auth: $auth';
}

/**
 * A firebase represents a particular location in your Firebase and can be used
 * for reading or writing data to that Firebase location.
 */
class Firebase extends Query {
  Disconnect _onDisconnect;

  /**
   * Construct a new Firebase reference from a full Firebase URL.
   */
  Firebase(String url) : super(url);

  /**
   * Construct a new Firebase reference from a JsObject.
   */
  Firebase.fromJsObject(JsObject obj) : super.fromJsObject(obj);

  /**
   * Getter for onDisconnect.
   */
  Disconnect get onDisconnect {
    if (_onDisconnect == null) {
      _onDisconnect = new Disconnect(_fb.callMethod('onDisconnect'));
    }
    return _onDisconnect;
  }

  /**
   * Authenticates a Firebase client using a provided Authentication token.
   * Takes a single token as an argument and returns a Future that will be
   * resolved when the authentication succeeds (or fails).
   */
  Future<AuthResponse> auth(String token) {
    var c = new Completer();
    // On failure, the first argument will be an Error object indicating the
    // failure. On success, the first argument will be null and the second
    // will be an object containing { auth: <auth payload>, expires:
    // <expiration time in seconds since the unix epoch> }.
    _fb.callMethod('auth', [token, (err, [result]) {
      if (err != null) {
        c.completeError(err);
      } else {
        c.complete(new AuthResponse(result));
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
    _fb.callMethod('unauth');
  }

  /**
   * Get a Firebase reference for a location at the specified relative path.
   * The relative path can either be a simple child name, (e.g. 'fred') or a
   * deeper slash seperated path (e.g. 'fred/name/first').
   */
  Firebase child(String path) =>
      new Firebase.fromJsObject(_fb.callMethod('child', [path]));

  /**
   * Get a Firebase reference for the parent location. If this instance refers
   * to the root of your Firebase, it has no parent, and therefore parent()
   * will return null.
   */
  Firebase parent() {
    var parentFb = _fb.callMethod('parent');
    return parentFb == null ? null : new Firebase.fromJsObject(parentFb);
  }

  /**
   * Get a Firebase reference for the root of the Firebase.
   */
  Firebase root() => new Firebase.fromJsObject(_fb.callMethod('root'));

  /**
   * The last token in a Firebase location is considered its name. Calling
   * name() on any Firebase reference will return this name. Calling name()
   * on the root of a Firebase will return null.
   */
  String name() => _fb.callMethod('name');

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
  Future set(value) {
    var c = new Completer();
    if (value is Map || value is Iterable) value = new JsObject.jsify(value);
    _fb.callMethod('set', [value, (err, res) {
      _resolveFuture(c, err, res);
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
  Future update(value) {
    var c = new Completer();
    if (value is Iterable || value is Map) {
      value = new JsObject.jsify(value);
    }
    _fb.callMethod('update', [value, (err, res) {
      _resolveFuture(c, err, res);
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
    _fb.callMethod('remove', [(err, res) {
      _resolveFuture(c, err, res);
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
   Firebase push({value}) => new Firebase.fromJsObject(_fb.callMethod('push', _removeNulls([value])));

   /**
    * Write data to a Firebase location, like set(), but also specify the
    * priority for that data. Identical to doing a set() followed by a
    * setPriority(), except it is combined into a single atomic operation to
    * ensure the data is ordered correctly from the start.
    *
    * Returns a Future which will complete when the data has been synchronized
    * with Firebase.
    */
   Future setWithPriority(value, int priority) {
     var c = new Completer();
     if (value is Map || value is Iterable) value = new JsObject.jsify(value);
     _fb.callMethod('setWithPriority', [value, priority, (err, res) {
       _resolveFuture(c, err, res);
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
   Future setPriority(int priority) {
     var c = new Completer();
     _fb.callMethod('setPriority', [priority, (err, res) {
       _resolveFuture(c, err, res);
     }]);
     return c.future;
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
   Future transaction(update(currentVal), {bool applyLocally}) {
     var c = new Completer();
     _fb.callMethod('transaction', [(var val) {
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

   /**
    * Resolve a future, given an error and result.
    */
   void _resolveFuture(Completer c, err, res) {
     if (err != null) {
       c.completeError(err);
     } else {
       c.complete(res);
     }
   }
}
