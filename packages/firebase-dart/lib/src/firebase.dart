library firebase.firebase;

import 'dart:js';
import 'dart:async';

import 'auth_response.dart';
import 'data_snapshot.dart';
import 'disconnect.dart';
import 'event.dart';
import 'transaction_result.dart';
import 'util.dart';

/**
 * A Firebase represents a particular location in your Firebase and can be used
 * for reading or writing data to that Firebase location.
 */
class Firebase extends Query {
  Stream<Event> _onAuth;
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
   *
   * auth in the Firebase JS library has been deprecated. The same behaviour is
   * now achieved by using authWithCustomToken
   */
  @deprecated
  Future auth(String token) {
    var c = new Completer();
    // On failure, the first argument will be an Error object indicating the
    // failure. On success, the first argument will be null and the second
    // will be an object containing { auth: <auth payload>, expires:
    // <expiration time in seconds since the unix epoch> }.
    _fb.callMethod('auth', [
      token,
      _getAuthCallback(c),
      (err, _) {
        c.completeError(err);
      }
    ]);
    return c.future;
  }

  /**
   * Authenticates a Firebase client using an authentication token or Firebase Secret.
   * Takes a single token as an argument and returns a Future that will be
   * resolved when the authentication succeeds (or fails).
   */
  Future authWithCustomToken(String token) {
    var c = new Completer();
    _fb.callMethod('authWithCustomToken', [token, _getAuthCallback(c)]);
    return c.future;
  }

  /**
   * Authenticates a Firebase client using a new, temporary guest account.
   */
  // https://www.firebase.com/docs/web/guide/login/anonymous.html#section-logging-in
  Future authAnonymously({remember: 'default'}) {
    var c = new Completer();
    _fb.callMethod('authAnonymously', [
      _getAuthCallback(c),
      jsify({'remember': remember})
    ]);
    return c.future;
  }

  /**
   * Authenticates a Firebase client using an email / password combination.
   */
  Future authWithPassword(Map credentials) {
    var c = new Completer();
    // On failure, the first argument will be an Error object indicating the
    // failure. On success, the first argument will be null and the second
    // will be an object containing { auth: <auth payload>, expires:
    // <expiration time in seconds since the unix epoch> }.
    _fb.callMethod(
        'authWithPassword', [jsify(credentials), _getAuthCallback(c)]);
    return c.future;
  }

  /**
   * Authenticates a Firebase client using a third party provider (github, twitter,
   * google, facebook). This method presents login form with a popup.
   */
  Future authWithOAuthPopup(provider, {remember: 'default', scope: ''}) {
    var c = new Completer();
    _fb.callMethod('authWithOAuthPopup', [
      provider,
      _getAuthCallback(c),
      jsify({'remember': remember, 'scope': scope})
    ]);
    return c.future;
  }

  /**
   * Authenticates a Firebase client using a third party provider (github, twitter,
   * google, facebook). This method redirects to a login form, then back to your app.
   */
  Future authWithOAuthRedirect(provider, {remember: 'default', scope: ''}) {
    var c = new Completer();
    _fb.callMethod('authWithOAuthRedirect', [
      provider,
      _getAuthCallback(c),
      jsify({'remember': remember, 'scope': scope})
    ]);
    return c.future;
  }

  /**
   * Authenticates a Firebase client using OAuth access tokens or credentials.
   */
  Future authWithOAuthToken(provider, credentials,
      {remember: 'default', scope: ''}) {
    var c = new Completer();
    _fb.callMethod('authWithOAuthToken', [
      provider,
      jsify(credentials),
      _getAuthCallback(c),
      jsify({'remember': remember, 'scope': scope})
    ]);
    return c.future;
  }

  ZoneBinaryCallback _getAuthCallback(Completer c) {
    return (err, [result]) {
      if (err != null) {
        c.completeError(err);
      } else {
        c.complete(decodeAuthData(result));
      }
    };
  }

  /**
   * Synchronously retrieves the current authentication state of the client.
   */
  dynamic getAuth() {
    var authResponse = _fb.callMethod('getAuth');
    return authResponse == null ? null : decodeAuthData(authResponse);
  }

  /**
   * Listens for changes to the client's authentication state.
   */
  Stream onAuth([context]) {
    if (_onAuth == null) {
      StreamController controller;

      if (context == null) {
        context = {};
      }

      void _handleOnAuth(authData) {
        if (authData != null) {
          controller.add(decodeAuthData(authData));
        } else {
          controller.add(null);
        }
      }

      void startListen() {
        _fb.callMethod('onAuth', [_handleOnAuth, jsify(context)]);
      }
      void stopListen() {
        _fb.callMethod('offAuth', [_handleOnAuth, jsify(context)]);
      }
      controller = new StreamController.broadcast(
          onListen: startListen, onCancel: stopListen, sync: false);
      return controller.stream;
    }
    return _onAuth;
  }

  /**
   * Unauthenticates a Firebase client (i.e. logs out).
   */
  void unauth() {
    _fb.callMethod('unauth');
  }

  /**
   * Get a Firebase reference for a location at the specified relative path.
   *
   * The relative path can either be a simple child name, (e.g. 'fred') or a
   * deeper slash separated path (e.g. 'fred/name/first').
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
   * Returns the last token in a Firebase location.
   * [key] on the root of a Firebase is `null`.
   */
  String get key => _fb.callMethod('key');

  /**
   * Gets the absolute URL corresponding to this Firebase reference's location.
   */
  String toString() {
    return _fb.toString();
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
  Future set(value) {
    var c = new Completer();
    value = jsify(value);
    _fb.callMethod('set', [
      value,
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
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
  Future update(Map<String, dynamic> value) {
    var c = new Completer();
    var jsValue = jsify(value);
    _fb.callMethod('update', [
      jsValue,
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
    return c.future;
  }

  /**
   * Remove the data at this Firebase location. Any data at child locations
   * will also be deleted.
   *
   * The effect of this delete will be visible immediately and the
   * corresponding events (onValue, onChildAdded, etc.) will be triggered.
   * Synchronization of the delete to the Firebase servers will also be
   * started, and the Future returned by this method will complete after the
   * synchronization has finished.
   */
  Future remove() {
    var c = new Completer();
    _fb.callMethod('remove', [
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
    return c.future;
  }

  /**
   * Push generates a new child location using a unique name and returns a
   * Firebase reference to it. This is useful when the children of a Firebase
   * location represent a list of items.
   *
   * The unique name generated by push() is prefixed with a client-generated
   * timestamp so that the resulting list will be chronologically sorted.
   */
  Firebase push({value, onComplete}) =>
      new Firebase.fromJsObject(_fb.callMethod('push', [
        value == null ? null : jsify(value),
        (err, _) {
          if (onComplete != null) {
            onComplete(err);
          }
        }
      ]));

  /**
   * Write data to a Firebase location, like set(), but also specify the
   * priority for that data. Identical to doing a set() followed by a
   * setPriority(), except it is combined into a single atomic operation to
   * ensure the data is ordered correctly from the start.
   *
   * Returns a Future which will complete when the data has been synchronized
   * with Firebase.
   */
  Future setWithPriority(value, priority) {
    var c = new Completer();
    value = jsify(value);
    _fb.callMethod('setWithPriority', [
      value,
      priority,
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
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
  Future setPriority(priority) {
    var c = new Completer();
    _fb.callMethod('setPriority', [
      priority,
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
    return c.future;
  }

  /**
   * Atomically modify the data at this location. Unlike a normal set(), which
   * just overwrites the data regardless of its previous value, transaction()
   * is used to modify the existing value to a new value, ensuring there are
   * no conflicts with other clients writing to the same location at the same
   * time.
   *
   * To accomplish this, you pass [transaction] an update function which is
   * used to transform the current value into a new value. If another client
   * writes to the location before your new value is successfully written,
   * your update function will be called again with the new current value, and
   * the write will be retried. This will happen repeatedly until your write
   * succeeds without conflict or you abort the transaction by not returning
   * a value from your update function.
   *
   * The returned [Future] will be completed after the transaction has
   * finished.
   */
  Future<TransactionResult> transaction(update(currentVal),
      {bool applyLocally: true}) {
    var c = new Completer();
    _fb.callMethod('transaction', [
      Zone.current.bindUnaryCallback((val) {
        var retValue = update(val);
        return jsify(retValue);
      }),
      (err, committed, snapshot) {
        if (err != null) {
          c.completeError(err);
        } else {
          snapshot = new DataSnapshot.fromJsObject(snapshot);
          c.complete(new TransactionResult(err, committed, snapshot));
        }
      },
      applyLocally
    ]);
    return c.future;
  }

  /**
   * Creates a new user account using an email / password combination.
   */
  Future createUser(Map credentials) {
    var c = new Completer();
    _fb.callMethod('createUser', [
      jsify(credentials),
      (err, [userData]) {
        _resolveFuture(c, err, userData);
      }
    ]);
    return c.future;
  }

  /**
   * Updates the email associated with an email / password user account.
   */
  Future changeEmail(Map credentials) {
    var c = new Completer();
    _fb.callMethod('changeEmail', [
      jsify(credentials),
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
    return c.future;
  }

  /**
   * Changes the password of an existing user using an email / password combination.
   */
  Future changePassword(Map credentials) {
    var c = new Completer();
    _fb.callMethod('changePassword', [
      jsify(credentials),
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
    return c.future;
  }

  /**
   * Removes an existing user account using an email / password combination.
   */
  Future removeUser(Map credentials) {
    var c = new Completer();
    _fb.callMethod('removeUser', [
      jsify(credentials),
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
    return c.future;
  }

  /**
   * Sends a password-reset email to the owner of the account, containing a
   * token that may be used to authenticate and change the user's password.
   */
  Future resetPassword(Map credentials) {
    var c = new Completer();
    _fb.callMethod('resetPassword', [
      jsify(credentials),
      (err, _) {
        _resolveFuture(c, err, null);
      }
    ]);
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

  static final ServerValue = new _ServerValue();
}

class _ServerValue {
  final TIMESTAMP = context['Firebase']['ServerValue']['TIMESTAMP'];
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
 * will only receive events and DataSnapshots for the subset of the data that
 * matches your query.
 */
class Query {
  /**
   * Holds a reference to the JavaScript 'Firebase' object.
   */
  final JsObject _fb;
  Stream<Event> _onValue;
  Stream<Event> _onChildAdded;
  Stream<Event> _onChildMoved;
  Stream<Event> _onChildChanged;
  Stream<Event> _onChildRemoved;

  /**
   * Construct a new default Query for a given URL.
   */
  Query(String url) : _fb = new JsObject(context['Firebase'], [url]);

  /**
   * Construct a new Query from a JsObject.
   */
  Query.fromJsObject(JsObject obj) : _fb = obj;

  /**
   * Helper function to create a new stream for a particular event type.
   */
  Stream<Event> _createStream(String type) {
    StreamController<Event> controller;

    // the first argument is to align with the implementation of
    // JsFunction.withThis – the first arg is 'this'
    void addEvent(_, snapshot, [prevChild]) {
      controller
          .add(new Event(new DataSnapshot.fromJsObject(snapshot), prevChild));
    }

    // using this wrapper to avoid a checked-mode warning about the function
    // not being a JSObject.
    var jsFunc = new JsFunction.withThis(addEvent);

    void startListen() {
      _fb.callMethod('on', [type, jsFunc]);
    }
    void stopListen() {
      _fb.callMethod('off', [type]);
    }
    controller = new StreamController<Event>.broadcast(
        onListen: startListen, onCancel: stopListen, sync: true);
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
   * Listens for exactly one event of the specified event type, and then stops
   * listening.
   */
  Future<DataSnapshot> once(String eventType) {
    var completer = new Completer<DataSnapshot>();

    _fb.callMethod('once', [
      eventType,
      (jsSnapshot) {
        var snapshot = new DataSnapshot.fromJsObject(jsSnapshot);
        completer.complete(snapshot);
      },
      (error) {
        completer.completeError(error);
      }
    ]);
    return completer.future;
  }

  /**
   * Generates a new Query object ordered by the specified child key.
   */
  Query orderByChild(String key) =>
      new Query.fromJsObject(_fb.callMethod('orderByChild', [key]));

  /**
   * Generates a new Query object ordered by key.
   */
  Query orderByKey() => new Query.fromJsObject(_fb.callMethod('orderByKey'));

  /**
   * Generates a new Query object ordered by child values.
   */
  Query orderByValue() =>
      new Query.fromJsObject(_fb.callMethod('orderByValue'));

  /**
   * Generates a new Query object ordered by priority.
   */
  Query orderByPriority() =>
      new Query.fromJsObject(_fb.callMethod('orderByPriority'));

  /**
   * Creates a Query with the specified starting point. The generated Query
   * includes children which match the specified starting point. If no arguments
   * are provided, the starting point will be the beginning of the data.
   *
   * The starting point is inclusive, so children with exactly the specified
   * priority will be included. Though if the optional name is specified, then
   * the children that have exactly the specified priority must also have a
   * name greater than or equal to the specified name.
   *
   * startAt() can be combined with endAt() or limitToFirst() or limitToLast()
   * to create further restrictive queries.
   */
  Query startAt({dynamic value, String key}) => new Query.fromJsObject(
      _fb.callMethod('startAt', _removeTrailingNulls([value, key])));

  /**
   * Creates a Query with the specified ending point. The generated Query
   * includes children which match the specified ending point. If no arguments
   * are provided, the ending point will be the end of the data.
   *
   * The ending point is inclusive, so children with exactly the specified
   * priority will be included. Though if the optional name is specified, then
   * children that have exactly the specified priority must also have a name
   * less than or equal to the specified name.
   *
   * endAt() can be combined with startAt() or limitToFirst() or limitToLast()
   * to create further restrictive queries.
   */
  Query endAt({dynamic value, String key}) => new Query.fromJsObject(
      _fb.callMethod('endAt', _removeTrailingNulls([value, key])));

  /**
   * Creates a Query which includes children which match the specified value.
   */
  Query equalTo(value, [key]) {
    var args = key == null ? [value] : [value, key];
    return new Query.fromJsObject(_fb.callMethod('equalTo', args));
  }

  /**
   * Generates a new Query object limited to the first certain number of children.
   */
  Query limitToFirst(int limit) =>
      new Query.fromJsObject(_fb.callMethod('limitToFirst', [limit]));

  /**
   * Generates a new Query object limited to the last certain number of children.
   */
  Query limitToLast(int limit) =>
      new Query.fromJsObject(_fb.callMethod('limitToLast', [limit]));

  /**
   * Generate a Query object limited to the number of specified children. If
   * combined with startAt, the query will include the specified number of
   * children after the starting point. If combined with endAt, the query will
   * include the specified number of children before the ending point. If not
   * combined with startAt() or endAt(), the query will include the last
   * specified number of children.
   */
  @deprecated
  Query limit(int limit) =>
      new Query.fromJsObject(_fb.callMethod('limit', [limit]));

  /**
   * Queries are attached to a location in your Firebase. This method will
   * return a Firebase reference to that location.
   */
  Firebase ref() => new Firebase.fromJsObject(_fb.callMethod('ref'));
}

List _removeTrailingNulls(List args) {
  while (args.isNotEmpty && args.last == null) {
    args.removeLast();
  }
  return args;
}
