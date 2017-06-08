import 'package:js/js_util.dart' as js;

import 'app.dart';
import 'auth.dart';
import 'database.dart';
import 'interop/firebase_interop.dart' as firebase;
import 'storage.dart';

export 'interop/firebase_interop.dart' show SDK_VERSION;

/// A (read-only) array of all the initialized Apps.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase#.apps>.
List<App> get apps =>
    firebase.apps.map((jsApp) => new App.fromJsObject(jsApp)).toList();

const String _defaultAppName = "[DEFAULT]";

/// Creates (and initializes) a Firebase App with API key, auth domain,
/// database URL and storage bucket.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase#.initializeApp>.
App initializeApp(
    {String apiKey,
    String authDomain,
    String databaseURL,
    String storageBucket,
    String name}) {
  name ??= _defaultAppName;

  try {
    return new App.fromJsObject(firebase.initializeApp(
        new firebase.FirebaseOptions(
            apiKey: apiKey,
            authDomain: authDomain,
            databaseURL: databaseURL,
            storageBucket: storageBucket),
        name));
  } catch (e) {
    if (_firebaseNotLoaded(e)) {
      throw new FirebaseJsNotLoadedException('firebase.js must be loaded.');
    }

    rethrow;
  }
}

App _app;

/// Retrieves an instance of an [App].
///
/// With no arguments, this returns the default App. With a single
/// string argument, it returns the named App.
///
/// This function throws an exception if the app you are trying
/// to access does not exist.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.app>.
App app([String name]) {
  var jsObject = (name != null) ? firebase.app(name) : firebase.app();

  if (_app != null) {
    _app.jsObject = jsObject;
  } else {
    _app = new App.fromJsObject(jsObject);
  }
  return _app;
}

Auth _auth;

/// Gets the [Auth] object for the default App or a given App.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth>.
Auth auth([App app]) {
  var jsObject = (app != null) ? firebase.auth(app.jsObject) : firebase.auth();

  if (_auth != null) {
    _auth.jsObject = jsObject;
  } else {
    _auth = new Auth.fromJsObject(jsObject);
  }
  return _auth;
}

Database _database;

/// Accesses the [Database] service for the default App or a given app.
///
/// The database is also a namespace that can be used to access
/// global constants and methods associated with the database service.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database>.
Database database([App app]) {
  var jsObject =
      (app != null) ? firebase.database(app.jsObject) : firebase.database();

  if (_database != null) {
    _database.jsObject = jsObject;
  } else {
    _database = new Database.fromJsObject(jsObject);
  }
  return _database;
}

Storage _storage;

/// The namespace for all the [Storage] functionality.
///
/// The returned service is initialized with a particular app which contains
/// the project's storage location, or uses the default app if none is provided.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage>.
Storage storage([App app]) {
  var jsObject =
      (app != null) ? firebase.storage(app.jsObject) : firebase.storage();

  if (_storage != null) {
    _storage.jsObject = jsObject;
  } else {
    _storage = new Storage.fromJsObject(jsObject);
  }
  return _storage;
}

/// Exception thrown when the firebase.js is not loaded.
class FirebaseJsNotLoadedException implements Exception {
  final String message;
  FirebaseJsNotLoadedException(this.message);

  @override
  String toString() => 'FirebaseJsNotLoadedException: $message';
}

bool _firebaseNotLoaded(error) {
  if (error is NoSuchMethodError) {
    return true;
  }

  if (js.hasProperty(error, 'message')) {
    var message = js.getProperty(error, 'message');
    return message == 'firebase is not defined' ||
        message == "Can't find variable: firebase";
  }

  return false;
}
