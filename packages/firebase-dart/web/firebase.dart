library Firebase;

import 'dart:js';
import 'dart:async';

class Firebase {
  JsObject _fb;

  /**
   * Construct a new Firebase reference from a full Firebase URL.
   */
  Firebase(String url) {
    this._fb = new JsObject(context['Firebase'], [url]);
  }

  /**
   * Construct a new Firebase reference from a JsObject.
   */
  Firebase.fromJsObject(JsObject obj) {
    this._fb = obj;
  }

  /**
   * Authenticates a Firebase client using a provided Authentication token.
   * Takes a single token as an argument and returns a Future that will be
   * resolved when the authentication succeeds (or fails).
   */
  Future auth(String token) {
    var c = new Completer();

    this._fb.callMethod('auth', [token, (error, result) {
      if (error) {
        c.completeError(error);
      } else {
        c.complete(result);
      }
    }, (error) {
      c.completeError(error);
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
    this._fb.callMethod('set', [value, (var err, var res) {
      if (err != null) {
        c.completeError(err);
      } else {
        c.complete(res);
      }
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
    this._fb.callMethod('update', [value, (var error) {
       if (error) {
         c.completeError(error);
       } else {
         c.complete(null);
       }
    }]);
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
    this._fb.callMethod('remove', [(var error) {
      if (error) {
        c.completeError(error);
      } else {
        c.complete(null);
      }
    }]);
  }
}
